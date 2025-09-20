document.addEventListener('DOMContentLoaded', function() {
  const shareButton = document.querySelector('.share-btn');
  if (shareButton) {
    shareButton.addEventListener('click', function() {
      const shareText = [
        "私の秋の世界を作成！",
        "楽しい景色作りに挑戦しています✨",
        "https://autumn-world.onrender.com/",
        "#RUNTEQ #プログラミング学習 #秋の世界"
      ].join("\n");  // ← 改行を正しく扱う

      const twitterUrl = `https://twitter.com/intent/tweet?text=${encodeURIComponent(shareText)}`;
      window.open(twitterUrl, '_blank', 'width=550,height=420');
    });
  }
});
