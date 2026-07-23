# Scenario Policy

## Scenario Request

親AgentはScenario Designerへ次を渡す。

```json
{
  "mode": "practice",
  "durationMinutes": 8,
  "requestedIndustry": null,
  "requestedPersona": null,
  "nextFocus": {
    "competency": "businessOutcome",
    "behavior": "回答の冒頭で経営成果と意思決定事項を示す"
  },
  "recurringWeaknesses": [],
  "masteredBehaviors": [],
  "coverage": {
    "industries": {},
    "personas": {},
    "capabilityLanes": {}
  },
  "recentScenarioIds": []
}
```

## 選択配分

- 50%: 直近の弱点を別業界または別能力レーンで再試験
- 25%: 習得済み行動を間隔反復
- 15%: 未経験の業界、役員、能力レーン
- 10%: 最新戦略または新しい論点。検証済みKnowledge Packがある場合のみ

長期のケース配分はMicrosoft中心とし、70%を単一または隣接製品、20%を全社横断、10%を延期・No-Go・非生成AIが妥当なケースにする。

## Scenario Pack

```json
{
  "scenarioId": "practice-template-id-variant",
  "mode": "practice",
  "title": "短い題名",
  "publicBrief": {
    "company": "規模と事業",
    "situation": "経営課題と現状",
    "availableFacts": ["計算可能な数値"],
    "decision": "今回求める意思決定",
    "responseFormat": "5分の経営会議提案"
  },
  "privateBrief": {
    "persona": "CFO",
    "personaPriorities": ["回収期間", "実現可能な便益"],
    "hiddenFacts": [
      { "revealOnTurn": 2, "fact": "予算が半減した" }
    ],
    "acceptableDirections": ["Adopt", "Extend", "Build", "Defer", "No-Go"],
    "unsupportedClaimsToWatch": ["根拠のない製品価格"]
  },
  "learningDesign": {
    "targetCompetency": "roiAndTco",
    "observableBehavior": "採用率と実現率を便益計算に含める",
    "transferFromPrevious": "別製品で同じROI能力を再試験",
    "difficulty": 2
  },
  "coverage": {
    "industry": "manufacturing",
    "persona": "CFO",
    "capabilityLanes": ["Adopt", "Extend", "GovernAndMeasure"]
  },
  "sourceTemplateId": "manufacturing-field-service"
}
```

## 品質ゲート

- 製品名を除いても経営ケースとして成立すること。
- 少なくとも2つの合理的な選択肢があること。
- 不足情報と仮定を区別できること。
- 受講者がROI、リスク、導入ロードマップの全てを議論できること。
- `observableBehavior`は発言からYes/Noを判定できること。
- Benchmarkはカタログの数値、イベント、難易度を変更しないこと。