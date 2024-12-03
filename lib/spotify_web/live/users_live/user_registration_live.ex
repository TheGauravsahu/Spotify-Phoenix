defmodule SpotifyWeb.UserRegistrationLive do
  use SpotifyWeb, :live_view

  alias Spotify.Users
  alias Spotify.Users.User

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-b from-[#1D1D1D] to-[#121212] flex items-center justify-center p-4">
      <div class="w-full max-w-md bg-[#282828] rounded-xl shadow-2xl border border-[#333] p-8">
        <h1 class="text-white text-4xl font-bold text-center mb-8">
          Sign up
        </h1>

        <.simple_form
          for={@form}
          id="registration_form"
          phx-submit="save"
          phx-change="validate"
          phx-trigger-action={@trigger_submit}
          action={~p"/users/log_in?_action=registered"}
          method="post"
          class="space-y-6"
        >
          <.error :if={@check_errors}>
            Oops, something went wrong! Please check the errors below.
          </.error>

          <div class="space-y-4">
            <.input
              field={@form[:email]}
              type="email"
              label="Email address"
              placeholder="Enter your email"
              class="bg-[#3B3B3B] border-none text-white placeholder-gray-500 focus:ring-2 focus:ring-green-500 rounded-full"
            />
            <.input
              field={@form[:password]}
              type="password"
              label="Password"
              placeholder="Create a password"
              class="bg-[#3B3B3B] border-none text-white placeholder-gray-500 focus:ring-2 focus:ring-green-500 rounded-full"
            />
          </div>

          <div class="text-sm text-gray-400 text-center mb-4">
            By creating an account, you agree to our
            <a href="#" class="text-green-500 hover:underline">Terms of Service</a>
            and <a href="#" class="text-green-500 hover:underline">Privacy Policy</a>.
          </div>

          <:actions>
            <.button
              phx-disable-with="Creating account..."
              class="w-full bg-green-500 hover:bg-green-600 text-black font-bold py-3 rounded-full transition-all duration-300 ease-in-out transform hover:scale-105"
            >
              Create account
            </.button>
          </:actions>
        </.simple_form>

        <div class="mt-6 text-center">
          <p class="text-gray-400">
            Already have an account?
            <.link navigate={~p"/users/log_in"} class="text-green-500 hover:underline font-semibold">
              Log in
            </.link>
          </p>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Users.change_user_registration(%User{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Users.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Users.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        changeset = Users.change_user_registration(user)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Users.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
