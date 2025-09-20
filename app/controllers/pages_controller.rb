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
    puts "effect_type: #{autumn_words[:effect_type]}"
    puts "effect_type class: #{autumn_words[:effect_type].class}"
      session[:used_words] << word
      if autumn_words[:effect_type] == "multiple"
        autumn_words[:effect_data].each do |effect|
          session[:landscape_state][effect] = "autumn"
        end
      else
        session[:landscape_state][autumn_words[:effect_type]] = autumn_words[:effect_data]
      end

      message_type = autumn_words[:effect_type] == "message_only" ? "story" : "success"

      puts "判定: #{autumn_words[:effect_type]} == 'message_only' → #{message_type}"

      render json: {
        success: true,
        message: autumn_words[:message],
        message_type: message_type,
        effect: autumn_words,
        effect_type: autumn_words[:effect_type]
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
  
    if params[:redirect_to] == 'game'
      redirect_to game_path
    else
      render json: {
        success: true,
        message: "世界が初期状態に戻りました！",
        reset: true
      }
    end
  end

  def complete
    @used_words = session[:used_words] || []
    @displayed_images_count = count_displayed_images
    @total_possible_images = 29
  
    @achievement_percentage = calculate_image_achievement_percentage(@displayed_images_count, @total_possible_images)
    @achievement_level = determine_achievement_level(@achievement_percentage)
    
    # 完成画面用に景色の状態を再構築
    build_complete_landscape_state
  end

  private

  def count_displayed_images
    displayed_count = 0

    displayed_count += 1 if session[:landscape_state]&.dig('trees_color') == 'autumn'
    displayed_count += 1 if session[:landscape_state]&.dig('mountain_color') == 'autumn'
    displayed_count += 1 if session[:landscape_state]&.dig('sky_color') == 'autumn'
    displayed_count += 1 if session[:landscape_state]&.dig('ground_color') == 'autumn'
    displayed_count += 1 if session[:landscape_state]&.dig('cloud_style') == 'autumn'
    displayed_count += 1 if session[:landscape_state]&.dig('grandma_style') == 'autumn'

    image_elements = [
      ['カエデ', '楓'],
      ['イチョウ', '銀杏'], 
      ['どんぐり'],
      ['読書'],
      ['りんご', 'リンゴ', '林檎'],
      ['焚き火', 'たき火'],
      ['栗'],
      ['さつまいも', 'やきいも'],
      ['金木犀'],
      ['柿'],
      ['ススキ', 'すすき'],
      ['リンドウ'],
      ['お月見'],
      ['猫'],
      ['犬'],
      ['赤とんぼ', 'とんぼ', 'トンボ'],
      ['コスモス'],
      ['ダリア'],
      ['秋刀魚', 'さんま'],
      ['落ち葉', 'もみじ', 'もみじ狩り'],
      ['筋トレ', 'スポーツ', '運動'],
      ['ハロウィン', 'ハロウィーン'],
      ['芸術']
    ]

    image_elements.each do |element_variations|
      if element_variations.any? { |word| session[:used_words]&.include?(word) }
        displayed_count += 1
      end
    end
    displayed_count
  end

  def calculate_image_achievement_percentage(displayed, total)
    return 0 if displayed == 0
    percentage = (displayed.to_f / total * 100).round(1)
    [percentage, 100.0].min
  end

  def determine_achievement_level(percentage)
    if percentage >= 100
       { 
         level: "✨", 
         title: "秋の世界の神様", 
         message: "完璧！あなたは秋の全てを表現しました！",
         color: "#E91E63"
       }
    elsif percentage >= 85
       { 
         level: "👑", 
         title: "秋の世界の創造主", 
         message: "ほぼ完璧な秋の世界です！",
         color: "#FF6B35"
       }
    elsif percentage >= 70
       { 
         level: "🏆", 
         title: "秋のアーティスト", 
         message: "素晴らしい秋の世界を創造しました！",
         color: "#FFD54F"
       }
    elsif percentage >= 50
       { 
         level: "🍁", 
         title: "秋の魔法使い", 
         message: "言葉で秋を自在に操っています！",
         color: "#FF8A65"
       }
    elsif percentage >= 30
       { 
         level: "🍂", 
         title: "秋の画家", 
         message: "美しい秋の風景を描いていますね！",
         color: "#FFB74D"
       }
    elsif percentage >= 15
       { 
         level: "🍃", 
         title: "秋を描く人", 
         message: "秋の色彩が少しずつ見えてきました！",
         color: "#AED581"
       }
    else  # 15%未満（0%含む）
       {
         level: "🌱",
         title: "秋の始まり",
         message: "秋の世界の扉がまもなく開かれます",
         color: "#81C784"
       }
    end
  end

  def build_complete_landscape_state
  # 初期状態（全てfalse）
    @landscape_state = {
      # 基本要素（景色の色変化など）
      'trees_color_autumn' => false,
      'mountain_color_autumn' => false,
      'sky_color_autumn' => false,
      'ground_color_autumn' => false,
      'cloud_style_autumn' => false,
      'grandma_style_autumn' => false,
      
      # 表示要素（画像レイヤー）- count_displayed_imagesと統一
      'maple' => check_word_variations(['カエデ', '楓']),
      'ginkgo' => check_word_variations(['イチョウ', '銀杏']),
      'grass' => check_word_variations(['ススキ', 'すすき']),
      'chestnut' => @used_words.include?('栗'),
      'book' => @used_words.include?('読書'),
      'acorns' => @used_words.include?('どんぐり'),
      'apple' => check_word_variations(['りんご', 'リンゴ', '林檎']),
      'dango' => @used_words.include?('お月見'),
      'cat' => @used_words.include?('猫'),
      'dog' => @used_words.include?('犬'),
      'fish' => check_word_variations(['秋刀魚', 'さんま']),
      'fire' => check_word_variations(['焚き火', 'たき火']),
      'persimmon' => @used_words.include?('柿'),
      'osmanthus' => @used_words.include?('金木犀'),
      'cosmos' => @used_words.include?('コスモス'),
      'dragonfly' => check_word_variations(['赤とんぼ', 'とんぼ', 'トンボ']),
      'leaves' => check_word_variations(['落ち葉', 'もみじ', 'もみじ狩り']),
      'dahlia' => @used_words.include?('ダリア'),
      'sweetpotato' => check_word_variations(['さつまいも', 'やきいも']),
      'gentian' => @used_words.include?('リンドウ'),
      'muscle' => check_word_variations(['筋トレ', 'スポーツ', '運動']),
      'halloween' => check_word_variations(['ハロウィン', 'ハロウィーン']),
      'art' => @used_words.include?('芸術')
    }
  
    # 使用された単語を全てチェックして景色の色変化を適用
    @used_words.each do |word|
    apply_autumn_effects(word)
    end
  end

  def apply_autumn_effects(word)
  # 既存のcheck_autumn_wordメソッドを活用
    autumn_data = check_autumn_word(word)
    return unless autumn_data
    
    case autumn_data[:effect_type]
    when "multiple"
      # 「紅葉」などの複数効果
      autumn_data[:effect_data].each do |effect|
        @landscape_state["#{effect}_autumn"] = true
      end
    when "sky_color", "ground_color", "cloud_style", "grandma_style"
      # 単一効果
      @landscape_state["#{autumn_data[:effect_type]}_autumn"] = true
    end
  end

  def check_word_variations(word_list)
  word_list.any? { |word| @used_words.include?(word) }
  end

  def check_autumn_word(word)
    autumn_data = {
      "紅葉" => { 
        effect_type: "multiple",
        effect_data: ["trees_color", "mountain_color"],
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
      "ハロウィン" => { effect_type: "add_nature", effect_data: "halloween", message: "ハッピーハロウィン！いぇあ！" },
      "ハロウィーン" => { effect_type: "add_nature", effect_data: "halloween", message: "ハッピーハロウィン！いぇあ！" },
      "芸術" => { effect_type: "add_nature", effect_data: "art", message: "おじいさんがおばあさんを見ながら、にこにこと絵を書いている。秋といえば、【絵を描くこと】" },
      "おじいさん" => { effect_type: "message_only", effect_data: "story", message: "おばあさん「おじいさんの趣味は絵を描くことだったわね、そう、芸術」" },
      "絵を描くこと" => { effect_type: "message_only", effect_data: "story", message: "おばあさん「絵といえば思い出すことがあってね、おじいさんね、秋にしてくれたの。プロポーズ」" },
      "プロポーズ" => { effect_type: "message_only", effect_data: "story", message: "おばあさん「『君の人生を描かせてほしい、結婚してください！』ってね。びっくりしたけど、なんかあれよね。ロマンチック」" },
      "ロマンチック" => { effect_type: "message_only", effect_data: "story", message: "おばあさん「ふふ、いい思い出だわ。おじいさん、去年、亡くなっちゃったけどね。こんな秋の日で、その年は、90歳」" },
      "90歳" => { effect_type: "message_only", effect_data: "story", message: "おばあさん「きっといまも、絵を書いているんでしょうね。そろそろお彼岸ね、あれをしなくちゃ。秋といえば、おじいさんのお墓参り」" },
      "おじいさんのお墓参り" => { effect_type: "message_only", effect_data: "story", message: "おばあさん「いまはみーちゃんもワン助も遊びにきてくれるから、楽しいのよ。話を聞いてくれてありがとね、楽しかったわ。」" },
    }

    autumn_data[word]
  end
end
