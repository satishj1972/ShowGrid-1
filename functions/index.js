const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// AI Scoring Cloud Function
exports.scoreImage = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "User must be logged in");
  }

  const { imageUrl, imageBase64, challengeTitle, challengeDescription, challengeCategory } = data;

  const apiKey = functions.config().openai?.key;
  if (!apiKey) {
    throw new functions.https.HttpsError("failed-precondition", "OpenAI API key not configured");
  }

  try {
    const prompt = `You are judging a submission for: "${challengeTitle}"
Description: ${challengeDescription}
${challengeCategory ? "Category: " + challengeCategory : ""}

Evaluate this image (1-10 scores):
1. Creativity - How original?
2. Quality - Technical quality
3. Relevance - Match to challenge?
4. Impact - Visual/emotional impact
5. Effort - Apparent effort

Respond ONLY with JSON:
{"creativity":<n>,"quality":<n>,"relevance":<n>,"impact":<n>,"effort":<n>,"overall_score":<avg>,"feedback":"<2-3 sentences>","highlights":["<s1>","<s2>"],"improvements":["<t1>","<t2>"]}`;

    const imageContent = imageBase64 
      ? { url: "data:image/jpeg;base64," + imageBase64, detail: "high" }
      : { url: imageUrl, detail: "high" };

    const response = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: { "Content-Type": "application/json", "Authorization": "Bearer " + apiKey },
      body: JSON.stringify({
        model: "gpt-4o",
        messages: [
          { role: "system", content: "You are an expert judge for ShowGrid. Respond only in valid JSON." },
          { role: "user", content: [{ type: "text", text: prompt }, { type: "image_url", image_url: imageContent }] }
        ],
        max_tokens: 1000,
        temperature: 0.3,
      }),
    });

    const result = await response.json();
    if (!response.ok) throw new Error(result.error?.message || "API error");

    let content = result.choices[0].message.content.trim();
    if (content.startsWith("```json")) content = content.substring(7);
    if (content.startsWith("```")) content = content.substring(3);
    if (content.endsWith("```")) content = content.substring(0, content.length - 3);

    const scoreData = JSON.parse(content.trim());

    await admin.firestore().collection("ai_scoring_logs").add({
      userId: context.auth.uid,
      challengeTitle,
      overallScore: scoreData.overall_score,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });

    return scoreData;
  } catch (error) {
    console.error("AI Scoring Error:", error);
    throw new functions.https.HttpsError("internal", error.message);
  }
});

exports.scoreAudio = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "User must be logged in");
  }

  const { transcript, chapterTitle, chapterDescription } = data;
  const apiKey = functions.config().openai?.key;
  
  if (!apiKey) {
    throw new functions.https.HttpsError("failed-precondition", "OpenAI API key not configured");
  }

  try {
    const prompt = `Judge this voice story for: "${chapterTitle}"
Description: ${chapterDescription}
Transcript: "${transcript}"

Score 1-10: Storytelling, Authenticity, Relevance, Emotional Impact, Clarity

Respond ONLY with JSON:
{"storytelling":<n>,"authenticity":<n>,"relevance":<n>,"emotional_impact":<n>,"clarity":<n>,"overall_score":<avg>,"feedback":"<2-3 sentences>","highlights":["<s1>"],"improvements":["<t1>"]}`;

    const response = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: { "Content-Type": "application/json", "Authorization": "Bearer " + apiKey },
      body: JSON.stringify({
        model: "gpt-4o",
        messages: [
          { role: "system", content: "You are an expert storytelling judge. Respond only in JSON." },
          { role: "user", content: prompt }
        ],
        max_tokens: 800,
        temperature: 0.3,
      }),
    });

    const result = await response.json();
    if (!response.ok) throw new Error(result.error?.message || "API error");

    let content = result.choices[0].message.content.trim();
    if (content.startsWith("```")) content = content.replace(/```json?|```/g, "");
    
    return JSON.parse(content.trim());
  } catch (error) {
    console.error("Audio Scoring Error:", error);
    throw new functions.https.HttpsError("internal", error.message);
  }
});
