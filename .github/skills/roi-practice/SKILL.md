---
name: roi-practice
description: 'Microsoft 365 Copilot、GitHub Copilot、Copilot Studio、Microsoft Foundry、Azure AIへの投資を題材に、経営層向けROI提案をロールプレイで訓練する。適応型ケース、独立採点、振り返り、学習履歴の更新を行う。'
argument-hint: '練習開始、業界、役員、難易度、またはbenchmark'
user-invocable: true
disable-model-invocation: false
---

# ROI Practice

Microsoft AIを題材に、製品説明ではなく経営の意思決定を支援する能力を訓練します。

## 参照順序

1. [Microsoft AI能力レーン](./references/microsoft-ai-portfolio.md)
2. [シナリオポリシー](./references/scenario-policy.md)
3. [採点ルーブリック](./references/rubric.md)
4. [状態スキーマ](./references/state-schema.md)
5. 練習時は[ケースカタログ](./references/scenario-catalog.json)、測定時は[Benchmarkカタログ](./references/benchmark-catalog.json)

## セッションモード

- `practice`: 学習履歴へ適応する通常練習。直近の弱点を別ケースへ転移する。
- `benchmark`: 固定された未公開ケースで成長を測る。出題を簡単にしない。
- `quick`: 1問1答と短い振り返り。採点と履歴更新は省略しない。

## オーケストレーション

1. 親Agentがプロファイルを読む。
2. Scenario DesignerへScenario Requestを渡す。
3. Executive Challengerを各ターン独立に呼び、親Agentが会話全文を再送する。
4. 本人の自己振り返りを採点前に取得する。
5. Evaluatorを過去情報なしで呼ぶ。
6. Reflection Coachへ自己評価、独立評価、前回目標を渡す。
7. `active-session.json`を作成し、`complete-session.ps1`で検証・保存・プロファイル更新を行う。

## 重要な原則

- 顧客成果から始める。Microsoft製品は手段である。
- ROIは時間削減だけでなく、実現率、採用率、TCO、測定方法を含める。
- 使用延期、No-Go、非生成AIが妥当なケースを含める。
- 価格、ライセンス、提供地域は基準日付きの公式情報がない限り断定しない。
- 日次Practice Scoreと固定Benchmark Scoreを混同しない。
- 毎回、次回に観測可能な行動を1つだけ設定する。