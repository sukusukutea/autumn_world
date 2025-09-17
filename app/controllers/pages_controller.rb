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
      "秋の空" => { effect_type: "sky_color", effect_data: "autumn", message: "空が秋の澄んだ青色に染まりました" },
      "秋晴れ" => { effect_type: "sky_color", effect_data: "autumn", message: "空が秋の澄んだ青色に染まりました" },
      "枯れ草" => { effect_type: "ground_color", effect_data: "autumn", message: "芝生が秋に色付きました" },
      "秋雲" => { effect_type: "cloud_style", effect_data: "autumn", message: "うろこ雲が浮かびました" },
      "うろこ雲" => { effect_type: "cloud_style", effect_data: "autumn", message: "うろこ雲が浮かびました" },
      "秋服" => { effect_type: "grandma_style", effect_data: "autumn", message: "おばあちゃんは秋の装いにしました" },
      "カーディガン" => { effect_type: "grandma_style", effect_data: "autumn", message: "おばあちゃんは秋の装いにしました" },
      "肌寒い" => { effect_type: "grandma_style", effect_data: "autumn", message: "おばあちゃんは秋の装いにしました" },
      "涼しい" => { effect_type: "grandma_style", effect_data: "autumn", message: "おばあちゃんは秋の装いにしました" },
      "柿" => { effect_type: "add_fruit", effect_data: "persimmon", message: "柿が鈴なりに実りました" },
      "ススキ" => { effect_type: "add_nature", effect_data: "grass", message: "遠くにススキ畑が広がりました" },
      "すすき" => { effect_type: "add_nature", effect_data: "grass", message: "遠くにススキ畑が広がりました" },
      "りんご" => { effect_type: "add_fruit", effect_data: "apple", message: "りんごの木が生えました" },
      "林檎" => { effect_type: "add_fruit", effect_data: "apple", message: "りんごの木が生えました" },
      "リンゴ" => { effect_type: "add_fruit", effect_data: "apple", message: "りんごの木が生えました" },
      "焚き火" => { effect_type: "add_nature", effect_data: "fire", message: "おばあちゃん「あったかいねえ」" },
      "たき火" => { effect_type: "add_nature", effect_data: "fire", message: "おばあちゃん「あったかいねえ」" },
      "秋刀魚" => { effect_type: "add_nature", effect_data: "fish", message: "秋刀魚の焼ける匂いがしてきた" },
      "さんま" => { effect_type: "add_nature", effect_data: "fish", message: "秋刀魚の焼ける匂いがしてきた" },
      "コスモス" => { effect_type: "add_nature", effect_data: "cosmos", message: "コスモスが顔をのぞかせました" },
      "猫" => { effect_type: "add_nature", effect_data: "cat", message: "おばあちゃん「あらミーちゃんきたの」" },
      "犬" => { effect_type: "add_nature", effect_data: "dog", message: "おばあちゃん「あらあらワン助が楽しそう」" },
      "お月見" => { effect_type: "add_nature", effect_data: "dango", message: "今晩のお月見の団子を用意しました" },
      "読書" => { effect_type: "add_nature", effect_data: "book", message: "おばあちゃんは読みかけの本を用意した" },
      "筋トレ" => { effect_type: "add_nature", effect_data: "muscle", message: "遠くで筋トレしている人がいる、秋ですね" },
      "スポーツ" => { effect_type: "add_nature", effect_data: "muscle", message: "筋トレはスポーツの一種でしょうか" },
      "運動" => { effect_type: "add_nature", effect_data: "muscle", message: "運動といえば筋トレですね、秋ですね" },
      "金木犀" => { effect_type: "add_nature", effect_data: "osmanthus", message: "金木犀の花が咲きました" },
      "落ち葉" => { effect_type: "add_nature", effect_data: "leaves", message: "落ち葉が舞うと綺麗ですね" },
      "もみじ" => { effect_type: "add_nature", effect_data: "leaves", message: "もみじが舞うと綺麗ですね" },
      "もみじ狩り" => { effect_type: "add_nature", effect_data: "leaves", message: "もみじが舞うと綺麗ですね" },
      "赤とんぼ" => { effect_type: "add_nature", effect_data: "dragonfly", message: "秋といえば赤とんぼですね" },
      "とんぼ" => { effect_type: "add_nature", effect_data: "dragonfly", message: "秋といえば赤とんぼですね" },
      "トンボ" => { effect_type: "add_nature", effect_data: "dragonfly", message: "秋といえば赤とんぼですね" },
      "ダリア" => { effect_type: "add_nature", effect_data: "dahlia", message: "ダリアは可憐で見応えがあります" },
      "栗" => { effect_type: "add_nature", effect_data: "chestnut", message: "栗の季節ですね！" },
      "どんぐり" => { effect_type: "add_nature", effect_data: "acorns", message: "おや、リスがどんぐり持って出てきましたよ" },
      "さつまいも" => { effect_type: "add_nature", effect_data: "sweetpotato", message: "さつまいも、おいしいよね" },
      "やきいも" => { effect_type: "add_nature", effect_data: "sweetpotato", message: "さつまいも、焼いて食べるとホクホクだね！" },
      "リンドウ" => { effect_type: "add_nature", effect_data: "gentian", message: "よく知ってましたね！リンドウも秋の花なんです" },
      "カエデ" => { effect_type: "add_nature", effect_data: "maple", message: "カエデの深い赤が美しいですね" },
      "楓" => { effect_type: "add_nature", effect_data: "maple", message: "楓の深い赤が美しいですね" },
      "イチョウ" => { effect_type: "add_nature", effect_data: "ginkgo", message: "遠くでイチョウの木が黄金に輝いている" },
      "銀杏" => { effect_type: "add_nature", effect_data: "ginkgo", message: "イチョウからとれる銀杏の香りは強烈ですね！" },
    }

    autumn_data[word]
  end
end
