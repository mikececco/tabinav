function displayLogo() {

  // const animation = document.querySelector("#animation")

  // if(animation) {
    console.log("logo")
    const logo = document.querySelector("#my-image");
    // logo.src = 'app/assets/images/le-wagon-logo.png';
    logo.style.display = 'block';
    logo.style.position = 'fixed';
    logo.style.top = '50%';
    logo.style.left = '-100px';
    document.body.appendChild(logo);
    animateLogo(logo);
  // }
}

function animateLogo(logo) {
  console.log("animate")

  const startX = -100; // start position of the logo
  const endX = window.innerWidth; // end position of the logo
  const duration = 3400; // animation duration in milliseconds

  let startTime = null;
  function step(timestamp) {
    if (!startTime) startTime = timestamp;
    const progress = timestamp - startTime;
    const percent = Math.min(progress / duration, 1);
    const x = startX + (endX - startX) * percent;
    logo.style.left = x + 'px';
    if (percent < 1) {
      window.requestAnimationFrame(step);
    }
  }
  window.requestAnimationFrame(step);
}

export { displayLogo }
