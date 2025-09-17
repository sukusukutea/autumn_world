import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sky", "trees", "ground", "message", "wordInput", "cloud", "mountain", "grandma", "persimmon"]
  static values = { 
    summerSky: String,
    autumnSky: String,
    summerTrees: String, 
    autumnTrees: String,
    summerGround: String,
    autumnGround: String,
    summerCloud: String,
    autumnCloud: String,
    summerMountain: String,
    autumnMountain: String,
    summerGrandma: String,
    autumnGrandma: String,
    persimmonImage: String,
  }

  connect() {
    console.log("ゲームコントローラー接続完了！")
  }

  changeElementImage(elementType, colorType) {
    const config = {
      tree: { target: this.treesTarget, autumnSrc: this.autumnTreesValue },
      mountain: { target: this.mountainTarget, autumnSrc: this.autumnMountainValue },
      ground: { target: this.groundTarget, autumnSrc: this.autumnGroundValue },
      sky: { target: this.skyTarget, autumnSrc: this.autumnSkyValue },
      cloud: { target: this.cloudTarget, autumnSrc: this.autumnCloudValue },
      grandma: { target: this.grandmaTarget, autumnSrc: this.autumnGrandmaValue }
    }

    const element = config[elementType]?.target
    if (!element || colorType !== "autumn") return

    console.log(`${elementType}を秋色に変更開始...`)
    
    // 共通アニメーション処理
    element.style.transition = "all 1.5s ease-in-out"
    element.style.filter = "hue-rotate(30deg) saturate(1.2)"
    
    setTimeout(() => {
      element.src = config[elementType].autumnSrc
      element.style.filter = "none"
      console.log(`${elementType}の変更完了`)
    }, 800)
  }

  // エンターキーでの入力処理
  handleEnter(event) {
    if (event.key === "Enter") {
      event.preventDefault()
      this.transformWorld()
    }
  }

  //メイン機能：世界に反映ボタンの処理
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

  addElement(elementType) {
    console.log(`${elementType}を追加開始...`)
  
    const elementConfig = {
      persimmon: { target: this.persimmonTarget, name: "柿" },
      apple: { target: this.appleTarget, name: "りんご" },
      maple: { target: this.mapleTarget, name: "もみじ" },
      leaves: { target: this.leavesTarget, name: "落ち葉" }
    }
  
    const config = elementConfig[elementType]
    if (!config) {
      console.warn(`未知の要素タイプ: ${elementType}`)
      return
    }
  
    const target = config.target

    const parentLayer = target.parentElement
      if (parentLayer && parentLayer.classList.contains('layer')) {
      parentLayer.style.display = "block"
      console.log(`${config.name}の親レイヤーを表示しました`)
    }

    // シンプルに表示状態にする
    target.style.display = "block"
    target.style.opacity = "1"
  
    console.log(`${config.name}の表示完了`)
  }

  //要素を削除する機能（アニメーションなし）
  removeElement(elementType) {
    console.log(`${elementType}を削除開始...`)
  
    const elementConfig = {
      persimmon: { target: this.persimmonTarget, name: "柿" },
      apple: { target: this.appleTarget, name: "りんご" },
      maple: { target: this.mapleTarget, name: "もみじ" },
      leaves: { target: this.leavesTarget, name: "落ち葉" }
      }
  
      const config = elementConfig[elementType]
      if (!config) return
  
      const target = config.target
      if (!target) return

      // 🔧 親要素（レイヤー）を非表示にする
      const parentLayer = target.parentElement
      if (parentLayer && parentLayer.classList.contains('layer')) {
      parentLayer.style.display = "none"
      console.log(`${config.name}の親レイヤーを非表示にしました`)
      }
  
      // シンプルに非表示にする
      target.style.display = "none"
  
      console.log(`${config.name}の削除完了`)
    }

  // エフェクト適用処理
  applyEffect(effect) {
    console.log("エフェクト適用:", effect)
  
    // 複数エフェクトの場合（紅葉で木と山が同時変化）
    if (effect.effect_type === "multiple") {
      console.log("複数エフェクト実行:", effect.effect_data)

      effect.effect_data.forEach((effectType) => {
        if (effectType === "tree_color") {
          this.changeTreeColor("autumn")
        }
        if (effectType === "mountain_color") {
          this.changeMountainColor("autumn")
        }
      })
      return // 複数エフェクトの場合はここで処理終了
    }
    
    switch (effect.effect_type) {
      case "sky_color":
        if (effect.effect_data === "autumn") {
          this.changeSkyColor("autumn")
        }
        break
      case "cloud_color":
        if (effect.effect_data === "autumn") {
          this.changeCloudStyle("autumn")
        }
        break
      case "ground_color":
        if (effect.effect_data === "autumn") {
          this.changeGroundColor("autumn")
        }
        break
      case "grandma_style":
        if (effect.effect_data === "autumn") {
          this.changeGrandmaStyle("autumn")
      }
      break
      case "add_fruit":
        if (effect.effect_data === "apple") {
          this.addElement("apple")
      } else if (effect.effect_data === "persimmon") {
        this.addElement("persimmon")
      }
      break
      case "add_nature":
      if (effect.effect_data === "maple") {
      this.addElement("maple")
      } else if (effect.effect_data === "leaves") {
        this.addElement("leaves")
      }
      break
      default:
        console.log("未対応のエフェクト:", effect.effect_type)
    }
  }

  // 木の色変更
  changeTreeColor(colorType) {
    this.changeElementImage('tree', colorType)
  }

    // 山の色変更
  changeMountainColor(colorType) {
    this.changeElementImage('mountain', colorType)
  }

  // 空の色変更
  changeSkyColor(colorType) {
    this.changeElementImage('sky', colorType)
  }

    // 雲の変更
  changeCloudStyle(colorType) {
    this.changeElementImage('cloud', colorType)
  }

  // 地面の色変更
  changeGroundColor(colorType) {
    this.changeElementImage('ground', colorType)
  }

  // グランマの変更
  changeGrandmaStyle(colorType) {
    this.changeElementImage('grandma', colorType)
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
        this.mountainTarget.src = this.summerMountainValue
        this.grandmaTarget.src = this.summerGrandmaValue
        this.removeElement("persimmon")
        
        // フィルターをリセット
        this.skyTarget.style.filter = "none"
        this.treesTarget.style.filter = "none"
        this.groundTarget.style.filter = "none"
        this.cloudTarget.style.filter = "none"
        this.mountainTarget.style.filter = "none"
        this.grandmaTarget.style.filter = "none"

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
