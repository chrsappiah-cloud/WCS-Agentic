"""
WCS Onboarding Agent Worker — mock identity extraction with policy-friendly output.
Replace mock with OCR/LLM in production; keep interface stable.
"""
from flask import Flask, jsonify, request

app = Flask(__name__)


@app.get("/health")
def health():
    return jsonify({"status": "ok"})


@app.post("/v1/extract-profile")
def extract_profile():
    body = request.get_json(force=True, silent=True) or {}
    email = body.get("email", "unknown@test.org")
    hint = body.get("documentHint", "passport")

    # Mock structured extraction (deterministic for tests)
    full_name = email.split("@")[0].replace(".", " ").title()
    return jsonify(
        {
            "fullName": full_name,
            "email": email,
            "documentType": hint,
            "confidence": 0.92,
            "riskScore": 0.12,
            "flags": [],
            "tokensUsed": 380,
            "model": "wcs-mock-extractor/1.0",
            "requiresHumanReview": hint != "passport",
        }
    )


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001)
