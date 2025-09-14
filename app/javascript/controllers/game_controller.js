import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["wordInput", "transformBtn", "message", "sky", "ground", "trees", "resetBtn"]

  connect() {
    console.log("ゲームコントローラー接続完了！🎮")
  }

  async transformWorld(event) {
    event.preventDefault()
    
    const word = this.wordInputTarget.value.trim()
    const submitButton = this.transformBtnTarget
    
    if (!word) {
      this.showMessage("言葉を入力してね！", "error")
      return
    }

    // ボタンを無効化（連続クリック防止）
    submitButton.disabled = true
    submitButton.textContent = "変化中..."

    try {
      const response = await fetch('/input_word', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({ word: word })
      })

      const data = await response.json()

      if (data.success) {
        this.showMessage(data.message, "success")
        this.applyEffect(data.effect)
        this.wordInputTarget.value = "" // 入力欄をクリア
      } else {
        this.showMessage(data.message, "error")
      }
    } catch (error) {
      console.error('エラー:', error)
      this.showMessage("何かエラーが発生しました...", "error")
    } finally {
      // ボタンを元に戻す
      submitButton.disabled = false
      submitButton.textContent = "世界に反映"
    }
  }

  async resetWorld(event) {
    event.preventDefault()
    
    const resetButton = this.resetBtnTarget
    
    // 確認ダイアログを表示
    if (!confirm("本当に最初の状態に戻しますか？これまでの変化がすべてリセットされます。")) {
      return
    }

    resetButton.disabled = true
    resetButton.textContent = "リセット中..."

    try {
      const response = await fetch('/reset_world', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        }
      })

      const data = await response.json()

      if (data.success) {
        this.showMessage(data.message, "success")
        this.resetToInitialState()
      } else {
        this.showMessage("リセットに失敗しました...", "error")
      }
    } catch (error) {
      console.error('エラー:', error)
      this.showMessage("何かエラーが発生しました...", "error")
    } finally {
      resetButton.disabled = false
      resetButton.textContent = "最初に戻る"
    }
  }

  // 🆕 画面を初期状態に戻す
  resetToInitialState() {
    // 木々を夏の状態に戻す
    const treesElement = this.treesTarget
    treesElement.style.transition = "all 1.5s ease-in-out"
    treesElement.style.filter = "none"
    
    // 画像を夏の木に変更
    setTimeout(() => {
      treesElement.src = treesElement.src.replace('trees_autumn', 'trees_summer')
    }, 750)

    // 空と地面も夏の状態に戻す（将来の拡張用）
    const skyElement = this.skyTarget
    const groundElement = this.groundTarget
    
    skyElement.src = skyElement.src.replace('sky_autumn', 'sky_summer')
    groundElement.src = groundElement.src.replace('ground_autumn', 'ground_summer')

    // 入力欄をクリア
    this.wordInputTarget.value = ""
  }

  applyEffect(effect) {
    console.log("エフェクト適用:", effect)
    
    switch(effect.effect_type) {
      case "tree_color":
        this.changeTreeColor(effect.effect_data)
        break
      case "add_fruit":
        this.addFruit(effect.effect_data)
        break
      default:
        console.log("未知のエフェクト:", effect.effect_type)
    }
  }

  changeTreeColor(colorType) {
    const treesElement = this.treesTarget
    
    if (colorType === "autumn") {
      // 夏の木から秋の木への変化アニメーション
      treesElement.style.transition = "all 1.5s ease-in-out"
      treesElement.style.filter = "hue-rotate(30deg) saturate(1.2)"
      
      // 画像を秋の木に変更
      setTimeout(() => {
        treesElement.src = treesElement.src.replace('trees_summer', 'trees_autumn')
        treesElement.style.filter = "none"
      }, 750)
    }
  }

  addFruit(fruitType) {
    // りんごなどのフルーツを追加する処理
    console.log(`${fruitType}を追加中...`)
    // 将来的にフルーツ画像を重ねる処理を実装
  }

  showMessage(text, type) {
    const messageElement = this.messageTarget
    messageElement.textContent = text
    messageElement.className = `message ${type}`
    
    // メッセージを3秒後に消す
    setTimeout(() => {
      messageElement.textContent = ""
      messageElement.className = "message"
    }, 3000)
  }
}