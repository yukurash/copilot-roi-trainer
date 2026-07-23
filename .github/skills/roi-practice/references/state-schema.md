# State Schema

`.roi-trainer/active-session.json`は次の形で保存する。`complete-session.ps1`が検証し、`sessions`へ移動して`profile.json`を更新する。

```json
{
  "schemaVersion": 1,
  "sessionId": "20260723T120000Z-short-id",
  "startedAt": "2026-07-23T12:00:00Z",
  "completedAt": "2026-07-23T12:10:00Z",
  "mode": "practice",
  "scenario": {
    "scenarioId": "scenario-id",
    "sourceTemplateId": "template-id",
    "industry": "manufacturing",
    "persona": "CFO",
    "capabilityLanes": ["Adopt", "GovernAndMeasure"],
    "targetCompetency": "roiAndTco",
    "observableBehavior": "採用率と実現率を含める"
  },
  "transcript": [
    { "speaker": "learner", "turn": 1, "text": "..." },
    { "speaker": "executive", "turn": 1, "text": "..." }
  ],
  "selfReflection": {
    "wentWell": "...",
    "stuckOn": "...",
    "wouldChange": "..."
  },
  "evaluation": {
    "scores": {
      "businessOutcome": { "score": 3, "evidence": "...", "gap": "..." },
      "roiAndTco": { "score": 3, "evidence": "...", "gap": "..." },
      "assumptionsAndMeasurement": { "score": 3, "evidence": "...", "gap": "..." },
      "riskAndGovernance": { "score": 3, "evidence": "...", "gap": "..." },
      "industryTransformation": { "score": 3, "evidence": "...", "gap": "..." },
      "executiveRecommendation": { "score": 3, "evidence": "...", "gap": "..." }
    },
    "overall": 3.0,
    "criticalIssues": []
  },
  "reflection": {
    "previousFocusObserved": false,
    "bottleneckCompetency": "roiAndTco",
    "bottleneckReason": "...",
    "nextBehavior": "次回に観測できる行動を1つ",
    "transferConstraint": "次回は別業界で再試験",
    "improvedAnswer": "60秒以内の回答例",
    "recurringWeaknesses": ["..."],
    "masteredBehaviors": []
  }
}
```

スコアは0から5の整数。`overall`は6軸の単純平均。会話本文には秘密情報を保存してよいが、記事などへ公開するときは匿名化する。