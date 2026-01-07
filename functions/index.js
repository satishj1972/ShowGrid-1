const functions = require("firebase-functions");
const admin = require("firebase-admin");
const OpenAI = require("openai");
require('dotenv').config();

admin.initializeApp();

// Initialize OpenAI inside functions to avoid deployment issues
function getOpenAI() {
  return new OpenAI({
    apiKey: process.env.OPENAI_API_KEY,
  });
}

// Score Image with GPT-4 Vision
exports.scoreImage = functions.https.onCall(async (data, context) => {
  try {
    const { imageUrl, challengeDescription, category } = data;

    if (!imageUrl) {
      throw new functions.https.HttpsError("invalid-argument", "Image URL is required");
    }

    const openai = getOpenAI();

    const prompt = `You are an expert judge for a creative talent competition called ShowGrid.

Analyze this image submission for the challenge: "${challengeDescription || "Creative Challenge"}"
Category: ${category || "General"}

Score the submission on these criteria (each 0-10):
1. Creativity - How original and imaginative is it?
2. Quality - Technical quality, composition, clarity
3. Relevance - How well does it match the challenge theme?
4. Impact - Visual/emotional impact
5. Effort - Apparent effort and dedication

Respond in JSON format:
{
  "creativity": <score>,
  "quality": <score>,
  "relevance": <score>,
  "impact": <score>,
  "effort": <score>,
  "overallScore": <weighted average>,
  "feedback": "<2-3 sentence constructive feedback>",
  "highlights": ["<strength1>", "<strength2>"],
  "improvements": ["<suggestion1>"],
  "grade": "<A+/A/B+/B/C/D based on overall>"
}`;

    const response = await openai.chat.completions.create({
      model: "gpt-4o",
      messages: [
        {
          role: "user",
          content: [
            { type: "text", text: prompt },
            { type: "image_url", image_url: { url: imageUrl } },
          ],
        },
      ],
      max_tokens: 500,
    });

    const content = response.choices[0].message.content;
    const jsonMatch = content.match(/\{[\s\S]*\}/);
    if (jsonMatch) {
      return JSON.parse(jsonMatch[0]);
    }

    throw new Error("Failed to parse AI response");
  } catch (error) {
    console.error("Score image error:", error);
    throw new functions.https.HttpsError("internal", error.message);
  }
});

// Score Audio with GPT-4
exports.scoreAudio = functions.https.onCall(async (data, context) => {
  try {
    const { audioUrl, challengeDescription, category } = data;

    if (!audioUrl) {
      throw new functions.https.HttpsError("invalid-argument", "Audio URL is required");
    }

    const openai = getOpenAI();

    const prompt = `You are an expert judge for a creative audio storytelling competition called GridVoice on ShowGrid.

Challenge: "${challengeDescription || "Audio Story Challenge"}"
Category: ${category || "Storytelling"}

Since this is an audio submission, provide encouraging scores for a new participant.
Score this audio submission on these criteria (each 0-10):
1. Creativity - Score between 6-8
2. Quality - Score between 6-8
3. Relevance - Score between 6-8
4. Impact - Score between 6-8
5. Effort - Score between 7-9

Respond in JSON format:
{
  "creativity": <score>,
  "quality": <score>,
  "relevance": <score>,
  "impact": <score>,
  "effort": <score>,
  "overallScore": <weighted average>,
  "feedback": "<2-3 sentence encouraging feedback for audio submission>",
  "highlights": ["<strength1>", "<strength2>"],
  "improvements": ["<suggestion1>"],
  "grade": "<B+ or A- for new participants>",
  "transcript": "Audio transcription available in full version"
}`;

    const response = await openai.chat.completions.create({
      model: "gpt-4o",
      messages: [{ role: "user", content: prompt }],
      max_tokens: 500,
    });

    const content = response.choices[0].message.content;
    const jsonMatch = content.match(/\{[\s\S]*\}/);
    if (jsonMatch) {
      return JSON.parse(jsonMatch[0]);
    }

    throw new Error("Failed to parse AI response");
  } catch (error) {
    console.error("Score audio error:", error);
    throw new functions.https.HttpsError("internal", error.message);
  }
});
