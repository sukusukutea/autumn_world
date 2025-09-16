class PagesController < ApplicationController
  def index
  end

  def game
    session[:used_words] ||= []
    session[:landscape_state] ||= {}
  end

  def input_word
    word = params[:word]&.strip&.downcase

    if word.blank?
      return render json: { success: false, message: "言葉を入力してね！" }
    end

    if session[:used_words].include?(word)
      return render json: { success: false, message: "その言葉は、すでにこの景色に反映されています！" }
    end

    autumn_words = check_autumn_word(word)

    if autumn_words
      session[:used_words] << word
      session[:landscape_state][autumn_words[:effect_type]] = autumn_words[:effect_data]

      render json: {
        success: true,
        message: autumn_words[:message],
        effect: autumn_words
      }
    else
      render json: {
        success: false,
        message: "その言葉は、まだこの世界の季節には追いついていないようです..."
      }
    end
  end
  
  def reset_world
    session[:used_words] = []
    session[:landscape_state] = {}
    
    render json: {
      success: true,
      message: "世界が初期状態に戻りました！",
      reset: true
    }
  end

  def complete
    @used_words = session[:used_words] || []
    @landscape_state = session[:landscape_state] || {}
  end

  def generate_share_image
    render json: { success: true }
  end

  private

  def check_autumn_word(word)
    autumn_data = {
      "紅葉" => { 
        effect_type: "multiple",
        effect_data: ["tree_color", "mountain_color"],
        message: "木々山々が美しく色づきました"
      },

      "秋空" => { effect_type: "sky_color", effect_data: "autumn", message: "空が秋の澄んだ青色に染まりました" },
      "秋晴れ" => { effect_type: "sky_color", effect_data: "autumn", message: "空が秋の澄んだ青色に染まりました" },
      "枯れ草" => { effect_type: "ground_color", effect_data: "autumn", message: "芝生が秋に色付きました" },
      "秋雲" => { effect_type: "cloud_style", effect_data: "autumn", message: "うろこ雲が浮かびました" },
      "うろこ雲" => { effect_type: "cloud_style", effect_data: "autumn", message: "うろこ雲が浮かびました" },
      "秋服" => { effect_type: "grandma_style", effect_data: "autumn", message: "おばあちゃんは秋の装いにしました" },
      "カーディガン" => { effect_type: "grandma_style", effect_data: "autumn", message: "おばあちゃんは秋の装いにしました" },
      "肌寒い" => { effect_type: "grandma_style", effect_data: "autumn", message: "おばあちゃんは秋の装いにしました" },
      "涼しい" => { effect_type: "grandma_style", effect_data: "autumn", message: "おばあちゃんは秋の装いにしました" },
      "柿" => { effect_type: "add_fruit", effect_data: "persimmon", message: "柿が鈴なりに実りました" },
    }

    autumn_data[word]
  end
end
