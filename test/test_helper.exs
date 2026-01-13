ExUnit.start()

# Set up Mox for HTTP client mocking
Mox.defmock(MercaEx.HTTPClientMock, for: MercaEx.HTTPClient)
Application.put_env(:merca_ex, :http_client, MercaEx.HTTPClientMock)
