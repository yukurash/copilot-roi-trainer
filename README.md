# Copilot ROI Trainer

Microsoft CopilotやAzure AIへの投資提案を題材に、経営層との対話を練習するVS Code向けマルチエージェントトレーナーです。

単なる製品知識の確認ではなく、経営課題、ROIとTCO、測定方法、データ保護、導入ロードマップ、意思決定依頼を一つの提案として組み立てる力を訓練します。

## 主な機能

- 希望するMicrosoft技術エリアと業界・業務領域から疑似ケースを生成
- CIO、CFO、CISO、CEOなどによる役員ロールプレイ
- 6軸の固定ルーブリックによる独立採点
- 自己振り返りと評価結果から、次回の改善行動を一つ設定
- 練習履歴を使った適応型出題と、固定ケースによるBenchmark
- Microsoft製品の採用ありきにせず、延期、No-Go、非生成AIも評価

## 必要な環境

- Visual Studio Code
- GitHub Copilot
- Custom Agents、Agent Skills、Subagentsを利用できるVS Code環境
- PowerShell 7以降

## セットアップ

```powershell
git clone https://github.com/yukurash/copilot-roi-trainer.git
code copilot-roi-trainer
```

VS CodeのChatでAgent pickerを開き、`ROI Trainer`を選択します。Agentが表示されない場合は、フォルダーがワークスペースのルートとして開かれていることを確認してからVS Codeウィンドウを再読み込みしてください。

## 使い方

`ROI Trainer`へ次のように入力します。

```text
練習開始
```

開始時に、今回扱う内容を確認されます。

1. **技術エリア**
   - Microsoft 365 Copilot
   - GitHub Copilot
   - Security Copilot
   - Copilot StudioとMicrosoft 365 Agent
   - Microsoft Foundryと独自AI
   - Azure AIサービス
   - ガバナンスと効果測定
   - 複数領域横断
   - 自由指定またはおまかせ
2. **業界・業務領域**
   - 業界の例: 製造、金融、小売、医療、公共、ソフトウェア
   - 業務の例: 営業、開発、顧客対応、セキュリティ、バックオフィス

最初のメッセージで指定することもできます。

```text
GitHub Copilotを使ったソフトウェア開発領域で、CFO向けの8分練習を開始
```

指定していない項目だけAgentが確認します。`おまかせ`を選ぶと、過去の弱点と未経験領域から選択されます。

スラッシュコマンドから通常練習またはBenchmarkを開始することもできます。

```text
/roi-practice
/roi-benchmark
```

## セッションの流れ

1. 技術エリアと業界・業務領域を選択
2. Scenario Designerが経営上の意思決定ケースを生成
3. 提案を回答
4. Executive Challengerが役員として反論や追加質問を提示
5. 自己振り返りを実施
6. Evaluatorが会話だけを使って独立採点
7. Reflection Coachが次回の観測可能な改善行動を設定
8. 結果を保存し、次回の出題へ反映

## Agent構成

| Agent | 役割 |
| --- | --- |
| ROI Trainer | セッション進行、ユーザー確認、履歴管理 |
| ROI Scenario Designer | 選択領域と学習履歴に合うケース設計 |
| ROI Executive Challenger | CIO、CFO、CISOなどの相手役 |
| ROI Evaluator | 固定ルーブリックによる独立採点 |
| ROI Reflection Coach | 自己評価と採点を次回の行動へ変換 |

サブエージェントはステートレスです。親の`ROI Trainer`がScenario Packと会話履歴を毎回渡し、学習状態の書き込みも一元管理します。

## 評価軸

各軸を0から5で評価します。

- 経営成果
- ROIとTCO
- 前提と効果測定
- リスクとガバナンス
- 業界変革
- エグゼクティブへの推奨

## 学習データ

初期状態は`.roi-trainer/profile.json`にあります。実行時に生成される以下のデータはGit管理されません。

- `.roi-trainer/active-session.json`
- `.roi-trainer/sessions/`
- `.roi-trainer/exports/`

通常練習の`Practice Score`は育成用です。成長を比較するときは、難易度を固定した`Benchmark Score`を使用します。

## 検証

```powershell
./.github/skills/roi-practice/scripts/validate-project.ps1
```

Agent定義、Skill参照、18件の練習テンプレート、6件のBenchmark、学習状態を検証します。

## 情報の扱い

製品の価格、ライセンス、提供地域、仕様は、ケースに根拠がない限り推測しません。学習用ケースではMicrosoft製品を選ばない判断も成立します。実際の提案に利用する情報は、最新のMicrosoft公式ドキュメントで確認してください。