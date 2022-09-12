const GenerateInstructions = {
  mounted() {
    console.log("Generating instructions...");
    var userkeyStashEl = document.getElementById("userkey-stash");
    var passphrase = userkeyStashEl.value;
    if (userkeyStashEl.value === "") {
      passphrase = "<Admin must provide the passphrase>";
    }

    var oobUrlEl = document.getElementById("oob-url");
    var instructionsEl = document.getElementById("instructions");
    var instructions = `1. Open this link in your browser
`+ oobUrlEl.value + `
2. When prompted, enter the following passphrase
`+ passphrase + `
`.trim()
    instructionsEl.textContent = instructions;

    userkeyStashEl.value = "";
  }

}
export default GenerateInstructions;