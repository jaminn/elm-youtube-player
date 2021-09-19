//youtube-player
customElements.define('youtube-player',
    class extends HTMLElement {
           connectedCallback() {
                var div = document.createElement("div");
                div.id = "player";
                this.appendChild(div);
           }
    }
);