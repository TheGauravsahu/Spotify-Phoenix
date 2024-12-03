defmodule SpotifyWeb.UserLoginLive do
  use SpotifyWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-b from-[#1D1D1D] to-[#121212] flex items-center justify-center p-4">
      <div class="w-full max-w-md bg-[#282828] rounded-xl shadow-2xl border border-[#333] p-8">
        <h1 class="text-white text-4xl font-bold text-center mb-8">
          Log in
        </h1>

        <.simple_form
          for={@form}
          id="login_form"
          action={~p"/users/log_in"}
          phx-update="ignore"
          class="space-y-6"
        >
          <div class="space-y-4">
            <.input
              field={@form[:email]}
              type="email"
              label="Email address"
              placeholder="Enter your email"
              class="bg-[#3B3B3B] border-none text-white placeholder-gray-500 focus:ring-2 focus:ring-green-500 rounded-full"
              required
            />

            <.input
              field={@form[:password]}
              type="password"
              label="Password"
              placeholder="Enter your password"
              class="bg-[#3B3B3B] border-none text-white placeholder-gray-500 focus:ring-2 focus:ring-green-500 rounded-full"
              required
            />
          </div>

          <div class="flex justify-between items-center text-sm text-gray-400">
           

            <.link
              href={~p"/users/reset_password"}
              class="text-green-500 hover:underline font-semibold"
            >
              Forgot password?
            </.link>
          </div>

          <.button
            phx-disable-with="Logging in..."
            class="w-full bg-green-500 hover:bg-green-600 text-black font-bold py-3 rounded-full transition-all duration-300 ease-in-out transform hover:scale-105"
          >
            Log in
          </.button>
        </.simple_form>

        <div class="mt-6 text-center">
          <p class="text-gray-400">
            Don't have an account?
            <.link navigate={~p"/users/register"} class="text-green-500 hover:underline font-semibold">
              Sign up
            </.link>
          </p>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
