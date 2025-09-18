document.addEventListener('DOMContentLoaded', function() {
  const shareButton = document.querySelector('.share-btn');
  if (shareButton) {
    shareButton.addEventListener('click', function() {
      const shareText = `私の秋の世界を作成中です！\n楽しい景色作りに挑戦しています✨\n\n#RUNTEQ #プログラミング学習 #秋の世界`;
      const twitterUrl = `https://twitter.com/intent/tweet?text=${encodeURIComponent(shareText)}`;
      window.open(twitterUrl, '_blank', 'width=550,height=420');
    });
  }
});
