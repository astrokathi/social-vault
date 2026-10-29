// Interactive quiz logic for ReelVault lessons
// Supports both class-based (.quiz-card / .quiz-option) and function-based (checkAnswer / .quiz-box)

function initQuiz(quizId, correctIndex, explanation) {
  const container = document.getElementById(quizId);
  if (!container) return;
  const buttons = container.querySelectorAll('.quiz-option, .quiz-btn');
  const feedback = container.querySelector('.quiz-feedback, #quiz-result');

  buttons.forEach((btn, idx) => {
    btn.addEventListener('click', () => {
      buttons.forEach(b => {
        b.classList.remove('correct', 'incorrect');
        b.disabled = true;
      });

      if (idx === correctIndex) {
        btn.classList.add('correct');
        if (feedback) {
          feedback.className = 'quiz-feedback success';
          feedback.innerHTML = '<strong>✓ Correct!</strong> ' + explanation;
        }
      } else {
        btn.classList.add('incorrect');
        if (buttons[correctIndex]) {
          buttons[correctIndex].classList.add('correct');
        }
        if (feedback) {
          feedback.className = 'quiz-feedback error';
          feedback.innerHTML = '<strong>✗ Incorrect.</strong> ' + explanation;
        }
      }
    });
  });
}

// Global fallback for lessons using inline onclick="checkAnswer(index, isCorrect)"
function checkAnswer(index, isCorrect) {
  const quizBox = document.getElementById('quiz-box') || document.querySelector('.quiz-box') || document.querySelector('.quiz-card');
  if (!quizBox) return;

  const buttons = quizBox.querySelectorAll('.quiz-btn, .quiz-option');
  const result = document.getElementById('quiz-result') || quizBox.querySelector('.quiz-feedback');

  buttons.forEach((btn, idx) => {
    btn.disabled = true;
    if (idx === index) {
      if (isCorrect) {
        btn.classList.add('correct');
      } else {
        btn.classList.add('incorrect');
      }
    }
  });

  if (result) {
    if (isCorrect) {
      result.className = 'quiz-feedback success';
      result.innerHTML = '<strong>✓ Excellent!</strong> You identified the correct architectural principle.';
    } else {
      result.className = 'quiz-feedback error';
      result.innerHTML = '<strong>✗ Incorrect.</strong> Review the technical explanation above to see why this constraint exists.';
    }
  }
}

// Auto-initialize standard quiz elements if not explicitly called
document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('.quiz-card, .quiz-box').forEach(card => {
    const buttons = card.querySelectorAll('.quiz-option, .quiz-btn');
    buttons.forEach((btn, idx) => {
      btn.setAttribute('tabindex', '0');
    });
  });
});
