// We import the CSS which is extracted to its own file by esbuild.
// Remove this line if you add a your own CSS build pipeline (e.g postcss).

// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import topbar from "../vendor/topbar"
import Hooks from "./hooks"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, { params: { _csrf_token: csrfToken }, hooks: Hooks })

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

function importKey(rawkey) {
  return window.crypto.subtle.importKey(
    "raw",
    rawkey,
    {
      name: "AES-GCM",
    },
    false, // non-extractable
    ["encrypt", "decrypt"]
  );
}

function exportKey(key) {
  return window.crypto.subtle.exportKey("raw", key);
}

function generateKey() {
  return window.crypto.subtle.generateKey(
    {
      name: "AES-GCM",
      length: 256,
    },
    true, // extractable
    ["encrypt", "decrypt"]
  );
}

function encrypt(data, key, iv) {
  return window.crypto.subtle.encrypt(alg(iv), key, data);
}

function decrypt(data, key, iv) {
  return window.crypto.subtle.decrypt(alg(iv), key, data);
}

function alg(iv) {
  return {
    name: "AES-GCM",
    iv: iv,
    tagLength: 128,
  };
}

function sha256(buffer) {
  return window.crypto.subtle.digest("SHA-256", buffer);
}

function arrayBufferToBase64(buffer) {
  var binary = '';
  var bytes = new Uint8Array(buffer);
  var len = bytes.byteLength;
  for (var i = 0; i < len; i++) {
    binary += String.fromCharCode(bytes[i]);
  }
  return window.btoa(binary);
}

function base64ToArrayBuffer(base64) {
  var binary_string = window.atob(base64);
  var len = binary_string.length;
  var bytes = new Uint8Array(len);
  for (var i = 0; i < len; i++) {
    bytes[i] = binary_string.charCodeAt(i);
  }
  return bytes.buffer;
}

window.addEventListener("error", (event) => {
  console.log("Error detected. Making sure the userkey is removed");
  var userkeyStashEl = document.getElementById("userkey-stash");
  if (userkeyStashEl) {
    userkeyStashEl.value = ""
  }
});

window.addEventListener("live-secret:clipcopy", (event) => {
  if ("clipboard" in navigator) {
    var instructionsEl = document.getElementById("instructions");
    const text = instructionsEl.textContent;
    navigator.clipboard.writeText(text);
  } else {
    alert("Sorry, your browser does not support clipboard copy.");
  }
});

window.addEventListener("live-secret:select-expiration", (event) => {
  console.log("Selecting expiration");
  event.target.value = event.detail.value
  event.target.dispatchEvent(
    new Event("input", { bubbles: true })
  )
});

async function createSecret(event) {
  var form = document.getElementById("secret-form");

  var writableElements = []
  var enabledElements = []

  // Disable everything while we encrypt
  console.log("Disabling form...");
  var elements = form.elements;
  for (var i = 0, len = elements.length; i < len; ++i) {
    var el = elements[i];
    if (el.readOnly == false) {
      el.readOnly = true;
      writableElements.push(el);
    }

    if (el.disabled == false) {
      el.disabled = true;
      enabledElements.push(el);
    }
  }

  var encoder = new TextEncoder();

  // Prepare or generate passphrase for the user
  var passphrase = document.getElementById("passphrase");
  var userkey = null;
  if (passphrase.value == "") {
    console.log("Generating passphrase...");
    encryptionkey = await generateKey();
    var rawkey = await exportKey(encryptionkey);
    userkey = arrayBufferToBase64(rawkey);

  } else {
    console.log("Found user provided passphrase");
    userkey = passphrase.value;
  }

  passphrase.value = ""
  passphrase.placeholder = "..."

  var userkeyBuffer = await sha256(encoder.encode(userkey));
  var encryptionkey = await importKey(userkeyBuffer);

  var ivEl = document.getElementById("iv");
  var iv = base64ToArrayBuffer(ivEl.value);

  // Read and clear the input in the form
  var cleartextEl = document.getElementById("cleartext");
  var data = encoder.encode(cleartextEl.value)
  cleartextEl.value = ""
  cleartextEl.placeholder = "..."

  var ciphertextBuffer = await encrypt(data, encryptionkey, iv);

  // Set hidden_input :content to the encrypted data
  var ciphertextEl = document.getElementById("ciphertext");
  ciphertextEl.value = arrayBufferToBase64(ciphertextBuffer);

  console.log("Submitting form...");

  // Enable everything that we disabled so that the phoenix submit works
  // Otherwise, there is no data in the submission.
  for (var i = 0, len = writableElements.length; i < len; ++i) {
    writableElements[i].readOnly = false;
  }

  for (var i = 0, len = enabledElements.length; i < len; ++i) {
    enabledElements[i].disabled = false;
  }

  form.dispatchEvent(
    new Event("submit", { bubbles: true, cancelable: true })
  )

  // Stash the passphrase
  var userkeyStashEl = document.getElementById("userkey-stash");
  userkeyStashEl.value = userkey;
}

async function decryptSecret() {
  var ciphertextEl = document.getElementById("ciphertext");
  var ivEl = document.getElementById("iv");
  var passphraseEl = document.getElementById("passphrase");

  var iv = base64ToArrayBuffer(ivEl.value);
  var userkey = passphraseEl.value;

  var encoder = new TextEncoder();

  var userkeyBuffer = await sha256(encoder.encode(userkey));
  var encryptionkey = await importKey(userkeyBuffer);
  var decryptedData = await decrypt(base64ToArrayBuffer(ciphertextEl.value), encryptionkey, iv);
  var decoder = new TextDecoder("utf-8");
  var res = decoder.decode(decryptedData)

  console.log(res)

}

window.addEventListener("live-secret:create-secret", createSecret);
window.addEventListener("live-secret:decrypt-secret", decryptSecret);