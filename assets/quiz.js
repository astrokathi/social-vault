// Interactive quiz logic for ReelVault lessons
function initQuiz(quizId, correctIndex, explanation) {
  const container = document.getElementById(quizId);
  if (!container) return;
  const buttons = container.querySelectorAll('.quiz-option');
  const feedback = container.querySelector('.quiz-feedback');

  buttons.forEach((btn, idx) => {
    btn.addEventListener('click', () => {
      // Clear previous styles
      buttons.forEach(b => {
        b.classList.remove('correct', 'incorrect');
        b.disabled = true;
      });

      if (idx === correctIndex) {
        btn.classList.add('correct');
        feedback.style.color = '#2ecc71';
        feedback.textContent = '✓ Correct! ' + explanation;
      } else {
        btn.classList.add('incorrect');
        buttons[correctIndex].classList.add('correct');
        feedback.style.color = 'var(--accent-pink)';
        feedback.textContent = '✗ Incorrect. ' + explanation;
      }
    });
  });
}
