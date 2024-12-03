defmodule SpotifyWeb.UserSettingsLive do
  use SpotifyWeb, :live_view

  alias Spotify.Users

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-b from-[#1D1D1D] to-[#121212] p-8">
      <div class="max-w-xl mx-auto bg-[#282828] rounded-xl shadow-2xl border border-[#333] p-8">
        <h1 class="text-white text-4xl font-bold text-center mb-8">
          Account Settings
        </h1>
        <p class="text-gray-400 text-center mb-8">
          Manage your account email address and password settings
        </p>

        <div class="space-y-12 divide-y divide-[#333]">
          <div class="pt-8">
            <h2 class="text-2xl text-white mb-6">Change Email</h2>
            <.simple_form
              for={@email_form}
              id="email_form"
              phx-submit="update_email"
              phx-change="validate_email"
              class="space-y-4"
            >
              <.input
                field={@email_form[:email]}
                type="email"
                label="Email"
                class="bg-[#3B3B3B] border-none text-white placeholder-gray-500 focus:ring-2 focus:ring-green-500 rounded-full"
                required
              />
              <.input
                field={@email_form[:current_password]}
                name="current_password"
                id="current_password_for_email"
                type="password"
                label="Current password"
                placeholder="Password"
                class="bg-[#3B3B3B] border-none text-white placeholder-gray-500 focus:ring-2 focus:ring-green-500 rounded-full"
                value={@email_form_current_password}
                required
              />
              <:actions>
                <.button
                  phx-disable-with="Changing..."
                  class="w-full bg-green-500 hover:bg-green-600 text-black font-bold py-3 rounded-full transition-all duration-300 ease-in-out transform hover:scale-105"
                >
                  Change Email
                </.button>
              </:actions>
            </.simple_form>
          </div>

          <div class="pt-8">
            <h2 class="text-2xl text-white mb-6">Change Password</h2>
            <.simple_form
              for={@password_form}
              id="password_form"
              action={~p"/users/log_in?_action=password_updated"}
              method="post"
              phx-change="validate_password"
              phx-submit="update_password"
              phx-trigger-action={@trigger_submit}
              class="space-y-4"
            >
              <input
                name={@password_form[:email].name}
                type="hidden"
                id="hidden_user_email"
                value={@current_email}
              />
              <.input
                field={@password_form[:password]}
                type="password"
                placeholder="New password"
                class="bg-[#3B3B3B] border-none text-white placeholder-gray-500 focus:ring-2 focus:ring-green-500 rounded-full"
                required
              />
              <.input
                field={@password_form[:password_confirmation]}
                type="password"
                placeholder="Confirm new password"
                class="bg-[#3B3B3B] border-none text-white placeholder-gray-500 focus:ring-2 focus:ring-green-500 rounded-full"
              />
              <.input
                field={@password_form[:current_password]}
                name="current_password"
                type="password"
                placeholder="Current password"
                id="current_password_for_password"
                class="bg-[#3B3B3B] border-none text-white placeholder-gray-500 focus:ring-2 focus:ring-green-500 rounded-full"
                value={@current_password}
                required
              />
              <:actions>
                <.button
                  phx-disable-with="Changing..."
                  class="w-full bg-green-500 hover:bg-green-600 text-black font-bold py-3 rounded-full transition-all duration-300 ease-in-out transform hover:scale-105"
                >
                  Change Password
                </.button>
              </:actions>
            </.simple_form>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # Rest of the implementation remains the same as the original
  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Users.update_user_email(socket.assigns.current_user, token) do
        :ok ->
          put_flash(socket, :info, "Email changed successfully.")

        :error ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    email_changeset = Users.change_user_email(user)
    password_changeset = Users.change_user_password(user)

    socket =
      socket
      |> assign(:current_password, nil)
      |> assign(:email_form_current_password, nil)
      |> assign(:current_email, user.email)
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  # Other event handlers remain the same
  def handle_event("validate_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    email_form =
      socket.assigns.current_user
      |> Users.change_user_email(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form, email_form_current_password: password)}
  end

  def handle_event("update_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Users.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Users.deliver_user_update_email_instructions(
          applied_user,
          user.email,
          &url(~p"/users/settings/confirm_email/#{&1}")
        )

        info = "A link to confirm your email change has been sent to the new address."
        {:noreply, socket |> put_flash(:info, info) |> assign(email_form_current_password: nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    password_form =
      socket.assigns.current_user
      |> Users.change_user_password(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form, current_password: password)}
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Users.update_user_password(user, password, user_params) do
      {:ok, user} ->
        password_form =
          user
          |> Users.change_user_password(user_params)
          |> to_form()

        {:noreply, assign(socket, trigger_submit: true, password_form: password_form)}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end
end
