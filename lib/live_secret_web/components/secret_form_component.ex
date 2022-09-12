defmodule LiveSecretWeb.SecretFormComponent do
  use Phoenix.Component
  import Phoenix.HTML.Form
  alias Phoenix.LiveView.JS

  def create(assigns) do
    ~H"""
    <!--
      This example requires Tailwind CSS v2.0+

      This example requires some changes to your config:

      ```
      // tailwind.config.js
      module.exports = {
        // ...
        plugins: [
          // ...
          require('@tailwindcss/forms'),
        ],
      }
      ```
    -->
    <.form let={f} for={@changeset} action="#" class="relative" id="secret-form" phx-change="validate" phx-submit="create">
      <div class="overflow-hidden rounded-lg border border-gray-300 shadow-sm focus-within:border-indigo-500 focus-within:ring-1 focus-within:ring-indigo-500">
        <%= label f, :content, class: "block text-xs font-medium text-gray-700 pt-2 px-2"%>
        <div phx-update="ignore" id="cleartext-div-for-ignore">
          <textarea id="cleartext" class="[-webkit-text-security:square] h-24 focus:[-webkit-text-security:none] pt-3 block w-full resize-none border-0 py-0 placeholder-gray-500 focus:ring-0" placeholder="Put your secret information here..." />
        </div>
        <%= hidden_input f, :content, id: "ciphertext" %>
        <%= hidden_input f, :iv, id: "iv" %>

        <!-- Spacer element to match the height of the toolbar -->
        <div aria-hidden="true">
          <div class="py-2">
            <div class="h-9"></div>
          </div>
          <div class="h-px"></div>
          <div class="py-2">
            <div class="py-px">
              <div class="h-9"></div>
            </div>
          </div>
        </div>
      </div>

      <div class="absolute inset-x-px bottom-0">
        <!-- Actions: These are just examples to demonstrate the concept, replace/wire these up however makes sense for your project. -->
        <div class="flex flex-nowrap justify-end space-x-2 py-2 px-2 sm:px-3">
          <div class="flex-shrink-0">
            <label id="listbox-label" class="sr-only"> Add an expiration </label>
            <div class="relative">
              <button type="button" class="relative inline-flex items-center whitespace-nowrap rounded-full bg-gray-50 py-2 px-2 text-sm font-medium text-gray-500 hover:bg-gray-100 sm:px-3" aria-haspopup="listbox" aria-expanded="true" aria-labelledby="listbox-label"
                phx-click={
                  JS.toggle(
                    to: "#expiration-popover"
                  )
                }
              >
                <!--
                  Heroicon name: mini/calendar
                -->
                <svg class="h-5 w-5 flex-shrink-0 text-gray-300 sm:-ml-1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                  <path fill-rule="evenodd" d="M5.75 2a.75.75 0 01.75.75V4h7V2.75a.75.75 0 011.5 0V4h.25A2.75 2.75 0 0118 6.75v8.5A2.75 2.75 0 0115.25 18H4.75A2.75 2.75 0 012 15.25v-8.5A2.75 2.75 0 014.75 4H5V2.75A.75.75 0 015.75 2zm-1 5.5c-.69 0-1.25.56-1.25 1.25v6.5c0 .69.56 1.25 1.25 1.25h10.5c.69 0 1.25-.56 1.25-1.25v-6.5c0-.69-.56-1.25-1.25-1.25H4.75z" clip-rule="evenodd" />
                </svg>
                <% duration = Ecto.Changeset.fetch_field!(@changeset, :duration) %>
                <span class="hidden truncate sm:ml-2 sm:block"><.duration v={duration} /></span>
                <%= hidden_input f, :duration, id: "duration" %>
              </button>

              <ul id="expiration-popover" class="hidden absolute right-0 z-10 mt-1 max-h-56 w-52 overflow-auto rounded-lg bg-white py-3 text-base shadow ring-1 ring-black ring-opacity-5 focus:outline-none sm:text-sm" tabindex="-1" role="listbox" aria-labelledby="listbox-label" aria-activedescendant="listbox-option-0"
                phx-click-away={JS.hide(to: "#expiration-popover")}
              >
                <%= for duration <- @durations do %>
                  <li class="bg-white relative cursor-default select-none py-2 px-3 hover:bg-gray-100" id={"expiration-"<>duration} role="option"
                  phx-click={JS.hide(to: "#expiration-popover") |> JS.dispatch("live-secret:select-expiration", to: "#duration", detail: %{"value" => duration})}
                  >
                    <div class="flex items-center">
                      <span class="block truncate font-medium"><.duration v={duration}/></span>
                    </div>
                  </li>
                <% end %>
              </ul>
            </div>
          </div>
        </div>
        <div class="flex items-center justify-between space-x-3 border-t border-gray-200 px-2 py-2 sm:px-3">
          <div class="flex w-full">
            <div class="w-full">
              <label class="block text-xs font-medium text-gray-700">Passphrase</label>
              <div phx-update="ignore" id="passphrase-div-for-ignore">
                <input type="text", id="passphrase" class="[-webkit-text-security:square] focus:[-webkit-text-security:none] block w-full border-0 text-sm font-medium placeholder-gray-500 focus:ring-0" placeholder="(generated)" >
              </div>
            </div>
          </div>
          <div class="flex-shrink-0">
            <button type="button" class="inline-flex items-center rounded-md border border-transparent bg-indigo-600 px-4 py-2 text-sm font-medium text-white shadow-sm hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
            phx-click={JS.dispatch("live-secret:create-secret")}
            >Create</button>
          </div>
        </div>
      </div>
    </.form>
    """
  end

  def duration(assigns) do
    ~H"""
    <%= case @v do %>
    <% "1h" -> %>
    1 hour
    <% "1d" -> %>
    1 day
    <% "3d" -> %>
    3 days
    <% "1w" -> %>
    1 week
    <% _ -> %>
    error
    <% end %>
    """
  end
end
