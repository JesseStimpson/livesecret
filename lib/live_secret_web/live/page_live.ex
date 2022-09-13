defmodule LiveSecretWeb.PageLive do
  use LiveSecretWeb, :live_view

  alias Phoenix.LiveView.JS
  alias LiveSecretWeb.{SecretFormComponent, ActiveUser}
  alias LiveSecret.{Presecret, Secret}

  @impl true
  def render(assigns) do
    ~H"""
    <!-- This example requires Tailwind CSS v2.0+ -->
    <!--
      This example requires updating your template:

      ```
      <html class="h-full bg-gray-100">
      <body class="h-full">
      ```
    -->
    <div class="min-h-full">
    <div class="bg-gray-800 pb-32">
      <header class="py-10">
        <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
          <h1 class="text-3xl font-bold tracking-tight text-white">LiveSecret</h1>
        </div>
      </header>
    </div>

    <main class="-mt-32">
      <div class="mx-auto max-w-7xl px-4 pb-12 sm:px-6 lg:px-8">
        <!-- Replace with your content -->
        <div class="rounded-lg bg-white px-5 py-6 shadow sm:px-6">

          <%= if @live_action == :create or @live_action == :admin do %>
            <!-- The encrypting passphase (either generated or user provided) is never transmitted to the server
                 so in order for the app.js to maintain temporary access to the value, we stash it in a location
                 that survives page updates from phx. app.js is responsible for managing this field safely -->
            <div phx-update="ignore" id="userkey-stash-div-for-ignore">
              <input type="hidden" id="userkey-stash">
            </div>
          <% end %>

          <%= unless is_nil(@id) do %>
          <LiveSecretWeb.BreadcrumbComponent.show
            home={Routes.page_path(@socket, :create)}
            id={@id}
            live_action={@live_action}
            burned_at={@burned_at}
            />
          <% end %>

          <%= case @special_action do %>
          <% :decrypting -> %>
            <% secret = read_secret_for_decrypt(@id) %>
            <.decrypt_modal secret={secret} changeset={Secret.changeset(secret, %{})} />
          <% _ -> %>
          <% end %>

          <%= case @live_action do %>
          <% :create -> %>
            <SecretFormComponent.create changeset={@changeset} modes={Presecret.supported_modes()}, durations={Presecret.supported_durations()}/>
          <% :admin -> %>

            <div class="p-4">
              <%= unless is_nil(@current_user) do %>
                <LiveSecretWeb.UserListComponent.view
                  self={@current_user.id}
                  live_action={@live_action}
                  users={@users}
                  burned_at={@burned_at}
                  />
              <% end %>
            </div>

          <% url = Application.fetch_env!(:live_secret, LiveSecretWeb.Endpoint)[:url] %>
          <% scheme = (url[:scheme] || "http") %>
          <% host = (url[:host] || "localhost") %>
          <% port = (url[:port] || 4000) %>
          <input type="hidden" id="oob-url", value={build_external_url(scheme, host, port, Routes.page_path(@socket, :receiver, @id))}>

            <.action_panel burned_at={@burned_at} />

          <% :receiver -> %>
            <div class="p-4">
              <%= unless is_nil(@current_user) do %>
                <LiveSecretWeb.UserListComponent.view self={@current_user.id} live_action={@live_action} users={@users} burned_at={@burned_at} />
              <% end %>
            </div>
          <% end %>
        </div>
        <!-- /End replace -->
      </div>
    </main>
    </div>
    """
  end

  defp decrypt_modal(assigns) do
    ~H"""
    <!-- This example requires Tailwind CSS v2.0+ -->
    <div id="decrypt-modal" class="relative z-10" aria-labelledby="modal-title" role="dialog" aria-modal="true">
    <!--
      Background backdrop, show/hide based on modal state.

      Entering: "ease-out duration-300"
        From: "opacity-0"
        To: "opacity-100"
      Leaving: "ease-in duration-200"
        From: "opacity-100"
        To: "opacity-0"
    -->
    <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity"></div>

    <div class="fixed inset-0 z-10 overflow-y-auto">
      <div class="flex min-h-full items-end justify-center p-4 text-center sm:items-center sm:p-0">
        <!--
          Modal panel, show/hide based on modal state.

          Entering: "ease-out duration-300"
            From: "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
            To: "opacity-100 translate-y-0 sm:scale-100"
          Leaving: "ease-in duration-200"
            From: "opacity-100 translate-y-0 sm:scale-100"
            To: "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
        -->
        <div class="relative transform overflow-hidden rounded-lg bg-white px-4 pt-5 pb-4 text-left shadow-xl transition-all sm:my-8 sm:w-full sm:max-w-lg sm:p-6">
          <div>
            <div class="mx-auto flex h-12 w-12 items-center justify-center rounded-full bg-red-100">
              <!-- Heroicon name: outline/lock-open -->
              <svg class="h-6 w-6 text-red-600" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" aria-hidden="true">
                <path d="M18 1.5c2.9 0 5.25 2.35 5.25 5.25v3.75a.75.75 0 01-1.5 0V6.75a3.75 3.75 0 10-7.5 0v3a3 3 0 013 3v6.75a3 3 0 01-3 3H3.75a3 3 0 01-3-3v-6.75a3 3 0 013-3h9v-3c0-2.9 2.35-5.25 5.25-5.25z" />
              </svg>
            </div>
            <div class="mt-3 text-center sm:mt-5">
              <h3 class="text-lg font-medium leading-6 text-gray-900" id="modal-title">Enter the passphrase</h3>
              <div class="mt-2">
                <p class="text-sm text-gray-500">Paste the passphrase into this box and click 'Decrypt'. The secret content will be shown if the passphrase is correct.</p>
              </div>
              <div class="pt-2" phx-update="ignore" id="passphrase-div-for-ignore">
                <input type="text" name="passphrase" id="passphrase" class="block w-full rounded-full border-gray-300 px-4 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm" placeholder="Passphrase">
              </div>
            </div>
          </div>

          <div id="ciphertext-div-for-ignore" phx-update="ignore">
            <input type="hidden" id="ciphertext" value={:base64.encode(@secret.content)} >
          </div>
          <div id="iv-div-for-ignore" phx-update="ignore">
            <input type="hidden" id="iv" value={:base64.encode(@secret.iv)} >
          </div>
          <div id="cleartext-div-for-ignore" phx-update="ignore">
            <textarea id="cleartext" hidden readonly class="h-24 pt-3 block w-full resize-none border-0 py-0 placeholder-gray-500 focus:ring-0 font-mono"/>
          </div>

          <%# phx-change="burn" will send the "burn" event as soon as the field is updated by app.js. There is no form submission %>
          <.form let={f} for={@changeset} phx-change="burn" autocomplete="off">
          <%= hidden_input f, :burn_key, id: "burnkey" %>
          </.form>

          <div id="decrypt-btns-div-for-ignore" phx-update="ignore" class="mt-5 sm:mt-6 sm:grid sm:grid-flow-row-dense sm:grid-cols-2 sm:gap-3">
            <button type="button" id="decrypt-btn" class="inline-flex w-full justify-center rounded-md border border-transparent bg-indigo-600 px-4 py-2 text-base font-medium text-white shadow-sm hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 sm:col-start-2 sm:text-sm"
            phx-click={JS.dispatch("live-secret:decrypt-secret")}
            >Decrypt</button>
            <button type="button" id="close-btn" class="mt-3 inline-flex w-full justify-center rounded-md border border-gray-300 bg-white px-4 py-2 text-base font-medium text-gray-700 shadow-sm hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 sm:col-start-1 sm:mt-0 sm:text-sm"
            phx-click={JS.hide(to: "#decrypt-modal")}
            >Close</button>
          </div>
        </div>
      </div>
    </div>
    </div>
    """
  end

  defp action_panel(assigns) do
    ~H"""
    <!-- This example requires Tailwind CSS v2.0+ -->
    <ul role="list" class="grid grid-cols-1 gap-6 sm:grid-cols-1 lg:grid-cols-2">

      <.action_item
      title="Burn this secret"
      description="When you burn the secret, the encrypted data is deleted forever."
      action_enabled={is_nil(@burned_at)}
      action_text="Burn secret"
      action_icon={:fire}
      action_class="text-red-700 bg-red-100 hover:bg-red-200 focus:ring-red-500"
      action_click="burn"
      >
      </.action_item>
      <.action_item
      title="Copy instructions"
      description="The recipient needs this information to decrypt the secret."
      action_enabled={is_nil(@burned_at)}
      action_text="Copy"
      action_icon={:clipboard}
      action_class="text-blue-700 bg-blue-100 hover:bg-blue-200 focus:ring-blue-500"
      action_click={JS.dispatch("live-secret:clipcopy")}
      >
      <%= if is_nil(@burned_at) do %>
                <div class="px-4 py-5 sm:p-6" id="instructions-div-for-ignore" phx-update="ignore">
                  <pre id="instructions" class="font-mono" phx-hook="GenerateInstructions">
                  </pre>
                </div>
      <% end %>
      </.action_item>
    </ul>
    """
  end

  defp action_item(assigns) do
    ~H"""
    <li class="col-span-1 rounded-lg bg-white shadow">
      <div class="flex w-full items-center justify-between space-x-6 p-6">
        <div class="flex-1 truncate">
          <div class="flex items-center space-x-3">
            <h3 class="truncate text-sm font-medium text-gray-900"><%= @title %></h3>
          </div>
          <p class="mt-1 truncate text-sm text-gray-500"><%= @description %></p>
        </div>
      </div>
      <div class="inline-flex w-full items-center justify-center pb-4">
        <button type="button" class={"#{@action_class} inline-flex items-center justify-center rounded-md border border-transparent px-4 py-2 font-medium focus:outline-none focus:ring-2 focus:ring-offset-2 sm:text-sm "<> if @action_enabled, do: "", else: "line-through"}
        phx-click={@action_click}
        disabled={not @action_enabled}
        >
        <%= @action_text %>
        <%= unless is_nil(@action_icon) do %>
        <.action_icon id={@action_icon} />
        <% end %>
        </button>
      </div>
      <div>
          <%= render_slot(@inner_block) %>
      </div>
    </li>
    """
  end

  defp action_icon(assigns) do
    ~H"""
    <%= case @id do %>
    <% :fire -> %>
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="ml-2 -mr-1 w-5 h-5">
      <path fill-rule="evenodd" d="M13.5 4.938a7 7 0 11-9.006 1.737c.202-.257.59-.218.793.039.278.352.594.672.943.954.332.269.786-.049.773-.476a5.977 5.977 0 01.572-2.759 6.026 6.026 0 012.486-2.665c.247-.14.55-.016.677.238A6.967 6.967 0 0013.5 4.938zM14 12a4 4 0 01-4 4c-1.913 0-3.52-1.398-3.91-3.182-.093-.429.44-.643.814-.413a4.043 4.043 0 001.601.564c.303.038.531-.24.51-.544a5.975 5.975 0 011.315-4.192.447.447 0 01.431-.16A4.001 4.001 0 0114 12z" clip-rule="evenodd" />
    </svg>
    <% :clipboard -> %>
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="ml-2 -mr-1 w-5 h-5">
    <path fill-rule="evenodd" d="M10.5 3A1.501 1.501 0 009 4.5h6A1.5 1.5 0 0013.5 3h-3zm-2.693.178A3 3 0 0110.5 1.5h3a3 3 0 012.694 1.678c.497.042.992.092 1.486.15 1.497.173 2.57 1.46 2.57 2.929V19.5a3 3 0 01-3 3H6.75a3 3 0 01-3-3V6.257c0-1.47 1.073-2.756 2.57-2.93.493-.057.989-.107 1.487-.15z" clip-rule="evenodd" />

    </svg>
    <% end %>
    """
  end

  defp build_external_url("https", host, 443, path) do
    "https://#{host}#{path}"
  end

  defp build_external_url(scheme, host, port, path) do
    "#{scheme}://#{host}:#{port}#{path}"
  end

  @impl true
  def mount(%{"id" => id, "key" => key}, %{}, socket = %{assigns: %{live_action: :admin}}) do
    %Secret{burned_at: burned_at, live?: live?} = LiveSecret.Repo.get!(Secret, id)

    {:ok,
     socket
     |> assert_creator_key(id, key)
     |> assign_current_user()
     |> assign(id: id, creator_key: key, burned_at: burned_at, special_action: nil, live?: live?)
     |> detect_presence()}
  end

  def mount(%{"id" => id}, %{}, socket = %{assigns: %{live_action: :receiver}}) do
    %Secret{burned_at: burned_at, live?: live?} = LiveSecret.Repo.get!(Secret, id)

    {:ok,
     socket
     |> assign_current_user()
     |> assign(id: id, burned_at: burned_at, special_action: nil, live?: live?)
     |> detect_presence()}
  end

  def mount(_params, %{}, socket = %{assigns: %{live_action: :create}}) do
    changeset = Presecret.changeset(Presecret.new(), %{})

    {:ok,
     socket
     |> assign_current_user()
     |> assign(id: nil, burned_at: nil, special_action: nil, live?: true)
     |> assign(changeset: changeset)}
  end

  @impl true

  # Validates form data during secret creation
  def handle_event(
        "validate",
        %{"presecret" => attrs},
        socket = %{assigns: %{changeset: _changeset}}
      ) do
    changeset =
      %Presecret{}
      |> Presecret.changeset(attrs)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset)}
  end

  # Submit form data for secret creation
  def handle_event("create", %{"presecret" => attrs}, socket) do
    attrs = Presecret.make_secret_attrs(attrs)

    {:ok, secret} =
      Secret.new()
      |> Secret.changeset(attrs)
      |> LiveSecret.Repo.insert()

    %Secret{id: id, creator_key: creator_key, burned_at: burned_at, live?: live?} = secret

    {:noreply,
     socket
     |> assign(
       id: id,
       creator_key: creator_key,
       changeset: nil,
       burned_at: burned_at,
       live?: live?
     )
     |> push_patch(to: Routes.page_path(socket, :admin, id, %{key: creator_key}))}
  end

  # Unlock a specific user for content decryption
  def handle_event(
        "unlock",
        %{"id" => user_id},
        socket = %{assigns: %{live_action: :admin, id: id}}
      ) do
    # presence meta must be updated from the "owner" process so we have to broadcast first
    # so that we can select the right user
    :ok = Phoenix.PubSub.broadcast(LiveSecret.PubSub, topic(id), {"unlocked", user_id})
    {:noreply, socket}
  end

  # Burn the secret so that no one else can access it
  def handle_event(
        "burn",
        params,
        socket = %{assigns: %{id: id, current_user: current_user, live_action: live_action, users: users}}
      ) do
    secret = LiveSecret.Repo.get!(Secret, id)

    # Assert allowed to burn
    case live_action do
      :admin ->
        :ok

      _ ->
        burn_key = params["secret"]["burn_key"]
        ^burn_key = secret.burn_key
    end

    burned_at = NaiveDateTime.utc_now()

    secret
    |> Secret.changeset(%{
      burn_key: nil,
      iv: nil,
      burned_at: burned_at,
      content: nil
    })
    |> LiveSecret.Repo.update!()

    :ok =
      Phoenix.PubSub.broadcast(
        LiveSecret.PubSub,
        topic(id),
        {"burned", current_user.id, burned_at}
      )

    case live_action do
      :receiver ->
        # change state to revealed
        active_user = users[current_user.id]
        LiveSecretWeb.Presence.update(self(), topic(id), current_user.id, %ActiveUser{
          active_user | state: :revealed
          })
      _ ->
        :ok
    end

    {:noreply,
     socket
     |> assign(burned_at: burned_at)
     |> put_burn_flash()}
  end

  # Catch-all for dev purposes
  def handle_event(event, params, socket) do
    IO.inspect({event, params})
    {:noreply, socket}
  end

  @impl true
  # Handle the push_patch after secret creation. We use a patch so that the DOM doesn't get
  # reset. This allows the client browser to hold onto the passphrase so the instructions
  # can be generated.
  def handle_params(
        %{"id" => id, "key" => key},
        _url,
        socket = %{assigns: %{live_action: :admin}}
      ) do
    %Secret{burned_at: burned_at, live?: live?} = LiveSecret.Repo.get!(Secret, id)

    {:noreply,
     socket
     |> assert_creator_key(id, key)
     |> assign(id: id, creator_key: key, burned_at: burned_at, live?: live?)
     |> detect_presence()}
  end

  # Catch-all for dev
  def handle_params(_, _, socket) do
    {:noreply, socket}
  end

  @impl true
  # Handles presence -- users coming online and offline from the page
  def handle_info(%Phoenix.Socket.Broadcast{event: "presence_diff", payload: diff}, socket) do
    {
      :noreply,
      socket
      |> handle_leaves(diff.leaves)
      |> handle_joins(diff.joins)
    }
  end

  # Broadcast to all listeners when a user is unlocked. However, only the specific user
  # should do anything with it.
  def handle_info(
        {"unlocked", user_id},
        socket = %{assigns: %{current_user: current_user, id: id, users: users}}
      ) do
    case current_user.id do
      ^user_id ->
        case users[user_id] do
          active_user = %ActiveUser{left_at: nil} ->
            {:ok, _} =
              LiveSecretWeb.Presence.update(self(), topic(id), user_id, %ActiveUser{
                active_user
                | state: :unlocked
              })

            {:noreply,
             socket
             |> assign(special_action: :decrypting)}

          _ ->
            {:noreply, socket}
        end

      _ ->
        {:noreply, socket}
    end
  end

  # All subscribers are informed the secret has been burned
  def handle_info(
        {"burned", burned_by, burned_at},
        socket = %{assigns: %{current_user: current_user}}
      ) do
    case current_user.id do
      ^burned_by ->
        {:noreply, socket}

      _ ->
        {:noreply,
         socket
         |> assign(burned_at: burned_at)
         |> put_burn_flash()}
    end
  end

  # Catch-all for dev
  def handle_info(info, socket) do
    IO.inspect(info, label: "info")
    {:noreply, socket}
  end

  defp handle_joins(socket, joins) do
    Enum.reduce(joins, socket, fn {user_id, %{metas: [active_user = %ActiveUser{} | _]}},
                                  socket ->
      assign(socket, :users, Map.put(socket.assigns.users, user_id, active_user))
    end)
  end

  defp handle_leaves(socket, leaves) do
    left_at = NaiveDateTime.utc_now()

    Enum.reduce(leaves, socket, fn {user_id, _}, socket ->
      users = socket.assigns.users

      case socket.assigns.users[user_id] do
        nil ->
          socket

        active_user ->
          active_user = %ActiveUser{active_user | left_at: left_at}

          socket
          |> assign(users: Map.put(users, user_id, active_user))
      end
    end)
  end

  def assert_creator_key(socket, id, key) do
    result = LiveSecret.Repo.get!(Secret, id)
    ^key = result.creator_key
    socket
  end

  defp topic(id) do
    "secret/#{id}"
  end

  def detect_presence(socket = %{assigns: %{presence: _}}) do
    socket
  end

  def detect_presence(
        socket = %{assigns: %{current_user: user, id: id, live_action: live_action, live?: live?}}
      )
      when not is_nil(user) do
    topic = topic(id)

    active_user = %ActiveUser{
      id: user[:id],
      live_action: live_action,
      joined_at: NaiveDateTime.utc_now(),
      state: if(live?, do: :locked, else: :unlocked)
    }

    special_action =
      case {live_action, active_user.state} do
        {_, :locked} -> nil
        {:admin, _} -> nil
        {:receiver, :unlocked} -> :decrypting
      end

    presence_pid =
      case LiveSecretWeb.Presence.track(self(), topic, user[:id], active_user) do
        {:ok, pid} ->
          pid

        {:error, {:already_tracked, pid, _topic, _userid}} ->
          pid
      end

    :ok = Phoenix.PubSub.subscribe(LiveSecret.PubSub, topic)

    socket
    |> assign(
      users: %{user.id => active_user},
      presence: presence_pid,
      special_action: special_action
    )
    |> handle_joins(LiveSecretWeb.Presence.list(topic))
  end

  def detect_presence(socket = %{assigns: %{id: id}}) do
    topic = topic(id)

    socket
    |> assign(users: %{})
    |> handle_joins(LiveSecretWeb.Presence.list(topic))
  end

  def connect_info?(socket) do
    case socket.private[:connect_info] do
      nil ->
        false

      %Plug.Conn{} ->
        # User id cannot be constructed until the websocket connects, so the first render
        # does not have a current_user so the presence list is not shown
        false

      _ ->
        true
    end
  end

  def connect_info_user(conn = %Plug.Conn{}) do
    connect_info_user(%{peer_data: Plug.Conn.get_peer_data(conn), label: "unknown connect info"})
  end

  def connect_info_user(_connect_info = %{peer_data: %{address: address, port: port}}) do
    address = :erlang.iolist_to_binary(:inet.ntoa(address))
    %{id: "#{address}:#{port}"}
  end

  def assign_current_user(socket = %{assigns: %{current_user: u}}) when not is_nil(u) do
    socket
  end

  def assign_current_user(socket) do
    if connect_info?(socket) do
      socket
      |> assign(current_user: connect_info_user(socket.private[:connect_info]))
    else
      socket
      |> assign(current_user: nil)
    end
  end

  defp read_secret_for_decrypt(id) do
    LiveSecret.Repo.get!(Secret, id)
  end

  def put_burn_flash(socket = %{assigns: %{live_action: :admin}}) do
    socket
    |> put_flash(
      :info,
      "Burned. Encrypted content deleted from LiveSecret server. Close this window."
    )
  end

  def put_burn_flash(socket = %{assigns: %{live_action: :receiver}}) do
    socket
    |> put_flash(
      :info,
      "The secret content has been deleted from the server. Please close this window."
    )
  end
end
