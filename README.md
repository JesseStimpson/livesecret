# LiveSecret

**LiveSecret** is a [Phoenix LiveView](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html)
web application built for secure sharing of passwords or other secrets.
The secret content is End-to-End Encrypted using your browser's built-in cryptography
library, [SubtleCrypto](https://developer.mozilla.org/en-US/docs/Web/API/SubtleCrypto).

## Disclaimer
LiveSecret has not undergone a third-party security audit, so it cannot provide
any guarantees regarding the technical claims made by the author. As a user
of LiveSecret you alone are responsible for securing secret content.

## Features
* End-to-End Encryption with out-of-band key
* Live Presence and Live-mode Secrets
* Burn after reading
* Link expiration
* Admin view

### E2EE with OOB key
When you author a secret with LiveSecret, it is encrypted within your browser. The ciphertext
is written to the server, but the cleartext is only held locally, and it's removed from your
browser's memory directly after the encryption event.

LiveSecret always uses a passphrase-like encryption key to encrypt the secret content. When you
author a secret, if you don't specifiy a passphrase, one will be generated for you. The passphrase
is always stored locally in the browser for the minimum amount of time necessary, and is never
transmitted to the server in any form.

As the author of a secret, you will be required to transmit the passphrase [out-of-band](https://en.wikipedia.org/wiki/Out-of-band_data) with the
intended recipient. You are responsible for the method used for this transmission.

### Live Presence
Each secret created with LiveSecret has a unique [non-enumerable URL](https://en.wikipedia.org/wiki/Network_enumeration).
When a someone renders this
URL in a browser, a Phoenix LiveView is loaded and the visitor's presence is tracked. All visitors
to this page can view the presence of all other users, and metadata is displayed for each including:

* Admin | Recipient
* Peer address and port
* Timestamp of joining | timestamp of leaving
* Locked | Unlocked | Revealed status

The LiveView is updated for all users as the secret is Decrypted and Burned. You never need to refresh
the page.

### Live-mode Secrets
When a secret is in Live mode, all users are Locked by default. When a user is in the Locked state,
the LiveSecret server will prevent the ciphertext from being sent to the client, preventing them from decrypting
the secret even if they have the passphrase. An Admin can Unlock a recipient by clicking the Locked
button in the Admin View. When a recipient is unlocked, they will be prompted for the passphrase, and if correct,
the cleartext content is displayed. This mode is useful for synchronous sharing of secrets.

When a secret is not in Live mode, all users are Unlocked by default. This mode is useful for asynchronous
sharing of secrets. However, if an attacker intercepts the URL and passphrase before the secret is burned,
they will be able to decrypt the message.

### Burn after reading
After a decryption, the ciphertext is deleted from the server immediately. This makes it very
likely that the cleartext is revealed to exactly 2 people via LiveSecret: the author and the
receiver. While we can't give a cryptographic guarantee that exactly 2 clients were involved,
Live Presence can help to bolster the likelihood. Also, Live-mode Secrets give near-certainty that
the cleartext is revealed only to the expected recipient.

Once burned, the URL can still be visited, but there are no actions to be taken by any party. A
burned secret is essentially a tombstone.

### Link expiration
When you author a secret, you choose the expiration period for all the information stored on the
server (ciphertext, iv, and metadata). After the expiration period, all this information will be
deleted from the server database. If a user visits the URL for this secret after the expiration,
they will be informed that the secret does not exist.

### Admin view
The author of the secret can perform a limited set of actions on the secret after creation. This
includes unlocking users in Live Presence, Burning the secret, and turning Live-mode on or off.
**The Admin View cannot view or decrypt the ciphertext.**

## Getting Started

To start the LiveSecret Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

## Next
1. Update UX/UI in the Recipient view (including Decryption Modal)
2. Ability to disable Live mode from Admin view
3. Whole-database encryption of the SQLite DB file ([reference](https://cone.codes/posts/encrypted-sqlite-with-ecto/))
4. Diceware-like passphrase generation from JS
5. Change "Joined at" to "Joined since" and update incrementing counter