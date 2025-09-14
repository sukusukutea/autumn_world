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
        message: "#{word}が世界に反映されました！",
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
      message: "世界が初期状態に戻りました！🌱",
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
      "紅葉" => { effect_type: "tree_color", effect_data: "autumn", message: "木々が美しく色づきました" },
      "もみじ" => { effect_type: "tree_color", effect_data: "autumn", message: "木々が美しく色づきました" },
      "りんご" => {effect_type: "add_fruit", effect_data: "apple", message: "赤いりんごが実りました"},
    }

    autumn_data[word]
  end
end
