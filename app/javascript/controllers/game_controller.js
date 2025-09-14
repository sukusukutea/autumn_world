import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sky", "trees", "ground", "message", "wordInput", "cloud"]
  static values = { 
    summerSky: String,
    autumnSky: String,
    summerTrees: String, 
    autumnTrees: String,
    summerGround: String,
    autumnGround: String,
    summerCloud: String,
    autumnCloud: String
  }

  connect() {
    console.log("ゲームコントローラー接続完了！")
    console.log("利用可能な画像パス:", {
      summerTrees: this.summerTreesValue,
      autumnTrees: this.autumnTreesValue,
      summerSky: this.summerSkyValue,
      autumnSky: this.autumnSkyValue,
      summerGround: this.summerGroundValue,
      autumnGround: this.autumnGroundValue,
      summerCloud: this.summerCloudValue,
      autumnCloud: this.autumnCloudValue,
    })
  }

  // エンターキーでの入力処理
  handleEnter(event) {
    if (event.key === "Enter") {
      event.preventDefault()
      this.transformWorld()
    }
  }

  // 🌟 メイン機能：世界に反映ボタンの処理
  async transformWorld() {
    const inputWord = this.wordInputTarget.value.trim()
    
    if (!inputWord) {
      this.showMessage("言葉を入力してください", "error")
      return
    }

    try {
      // サーバーにAjaxリクエストを送信
      const response = await fetch('/input_word', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({ word: inputWord })
      })

      const data = await response.json()
      
      if (data.success) {
        // 成功時の処理
        this.showMessage(data.message, "success")
        
        // エフェクトがある場合は適用
        if (data.effect) {
          this.applyEffect(data.effect)
        }
        
        // 入力欄をクリア
        this.wordInputTarget.value = ""
      } else {
        // 失敗時の処理
        this.showMessage(data.message, "error")
      }
    } catch (error) {
      console.error('エラーが発生しました:', error)
      this.showMessage("通信エラーが発生しました", "error")
    }
  }

  // エフェクト適用処理
  applyEffect(effect) {
    console.log("エフェクト適用:", effect)
    
    switch (effect.effect_type) {
      case "tree_color":
        if (effect.effect_data === "autumn") {
          this.changeTreeColor("autumn")
        }
        break
      case "sky_color":
        if (effect.effect_data === "autumn") {
          this.changeSkyColor("autumn")
        }
        break
      case "cloud_style":
        if (effect.effect_data === "autumn") {
          this.changeCloudStyle("autumn")
        }
        break
      case "ground_color": // 追加
      if (effect.effect_data === "autumn") {
        this.changeGroundColor("autumn")
      }
      break
      case "add_fruit":
      if (effect.effect_data === "apple") {
        this.addFruit("apple")
      }
      break
      default:
        console.log("未対応のエフェクト:", effect.effect_type)
    }
  }

  // 木の色変更（メイン機能）
  changeTreeColor(colorType) {
    const treesElement = this.treesTarget
    
    if (colorType === "autumn") {
      console.log("木を秋色に変更開始...")
      console.log("現在の画像パス:", treesElement.src)
      
      // 変化アニメーション
      treesElement.style.transition = "all 1.5s ease-in-out"
      treesElement.style.filter = "hue-rotate(30deg) saturate(1.2)"
      
      // 画像を秋の木に変更
      setTimeout(() => {
        treesElement.src = this.autumnTreesValue
        treesElement.style.filter = "none"
        console.log("木の変更完了:", treesElement.src)
      }, 800)
    }
  }

  // 🍎 果物追加機能
  addFruit(fruitType) {
    const treesElement = this.treesTarget
    const treesContainer = treesElement.parentElement
    
    if (fruitType === "apple") {
      // 既存の果物を削除（重複防止）
      const existingFruits = treesContainer.querySelectorAll('.fruit')
      existingFruits.forEach(fruit => fruit.remove())
      
      // りんごを複数個追加
      const applePositions = [
        { left: '25%', top: '30%' },
        { left: '40%', top: '25%' },
        { left: '60%', top: '35%' },
        { left: '75%', top: '28%' }
      ]
      
      applePositions.forEach((position, index) => {
        setTimeout(() => {
          const apple = document.createElement('div')
          apple.className = 'fruit apple'
          apple.style.cssText = `
            position: absolute;
            left: ${position.left};
            top: ${position.top};
            width: 20px;
            height: 20px;
            background: radial-gradient(circle at 30% 30%, #ff6b6b, #d63031);
            border-radius: 50%;
            transform: scale(0);
            transition: transform 0.5s ease-out;
            z-index: 10;
            box-shadow: 2px 2px 4px rgba(0,0,0,0.3);
          `
          
          treesContainer.appendChild(apple)
          
          // アニメーション開始
          setTimeout(() => {
            apple.style.transform = 'scale(1)'
          }, 50)
        }, index * 200)
      })
      
      console.log("りんごを追加しました")
    }
  }

  // 空の色変更
  changeSkyColor(colorType) {
    const skyElement = this.skyTarget
    
    if (colorType === "autumn") {
      console.log("空を秋色に変更開始...")
      
      // 変化アニメーション
      skyElement.style.transition = "all 2s ease-in-out"
      skyElement.style.filter = "hue-rotate(20deg) saturate(1.1) brightness(0.9)"
      
      // 画像を秋の空に変更
      setTimeout(() => {
        skyElement.src = this.autumnSkyValue
        skyElement.style.filter = "none"
        console.log("空の変更完了:", skyElement.src)
      }, 1000)
    }
  }

    // 雲の変更
  changeCloudStyle(styleType) {
    const cloudElement = this.cloudTarget
    
    if (styleType === "autumn") {
      console.log("雲をうろこ雲に変更...")
      
      // 変化アニメーション
      cloudElement.style.transition = "all 2s ease-in-out"
      cloudElement.style.filter = "hue-rotate(20deg) saturate(1.1) brightness(0.9)"
      
      // 画像をうろこ雲に変更
      setTimeout(() => {
        cloudElement.src = this.autumnCloudValue
        cloudElement.style.filter = "none"
        console.log("雲の変更完了:", cloudElement.src)
      }, 1000)
    }
  }

  // 地面の色変更
  changeGroundColor(colorType) {
    const groundElement = this.groundTarget
    
    if (colorType === "autumn") {
      console.log("地面を秋色に変更開始...")
      
      // 変化アニメーション
      groundElement.style.transition = "all 1.8s ease-in-out"
      groundElement.style.filter = "hue-rotate(25deg) saturate(1.3) brightness(0.95)"
      
      // 画像を秋の地面に変更
      setTimeout(() => {
        groundElement.src = this.autumnGroundValue
        groundElement.style.filter = "none"
        console.log("地面の変更完了:", groundElement.src)
      }, 900)
    }
  }

  // 🔄 世界をリセット
  async resetWorld() {
    try {
      const response = await fetch('/reset_world', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        }
      })

      const data = await response.json()
      
      if (data.success) {
        // 成功メッセージ表示
        this.showMessage(data.message, "success")
        
        // 画像を夏の状態に戻す
        this.skyTarget.src = this.summerSkyValue
        this.treesTarget.src = this.summerTreesValue
        this.groundTarget.src = this.summerGroundValue
        this.cloudTarget.src = this.summerCloudValue
        
        // フィルターをリセット
        this.skyTarget.style.filter = "none"
        this.treesTarget.style.filter = "none"
        this.groundTarget.style.filter = "none"
        this.cloudTarget.style.filter = "none"
        
        // 果物を削除
        const fruits = document.querySelectorAll('.fruit')
        fruits.forEach(fruit => fruit.remove())
        
        // 入力欄をクリア
        this.wordInputTarget.value = ""
        
        console.log("🔄 世界をリセットしました")
      } else {
        this.showMessage("リセットに失敗しました", "error")
      }
    } catch (error) {
      console.error('リセットエラー:', error)
      this.showMessage("通信エラーが発生しました", "error")
    }
  }

  // 💬 メッセージ表示機能
showMessage(text, type = "info") {
    const messageElement = this.messageTarget
    
    // メッセージのスタイル設定
    const styles = {
      success: { color: "#27ae60", background: "#d5f4e6" },
      error: { color: "#e74c3c", background: "#fdf2f2" },
      warning: { color: "#f39c12", background: "#fef9e7" },
      info: { color: "#3498db", background: "#eaf4fd" }
    }
    
    const style = styles[type] || styles.info
    
    messageElement.textContent = text
    messageElement.style.cssText = `
      padding: 15px 20px;
      margin: 10px 0;
      border-radius: 8px;
      font-weight: bold;
      text-align: center;
      color: ${style.color};
      background-color: ${style.background};
      border: 2px solid ${style.color};
      opacity: 0;
      transform: translateY(-10px);
      transition: all 0.3s ease-out;
    `
    
    // アニメーション表示
    setTimeout(() => {
      messageElement.style.opacity = "1"
      messageElement.style.transform = "translateY(0)"
    }, 50)
    
    // 3秒後に自動で非表示
    setTimeout(() => {
      messageElement.style.opacity = "0"
      messageElement.style.transform = "translateY(-10px)"
      
      setTimeout(() => {
        messageElement.textContent = ""
        messageElement.style.cssText = ""
      }, 300)
    }, 3000)
    
    console.log(`💬 メッセージ表示: ${text} (${type})`)
  }
}
