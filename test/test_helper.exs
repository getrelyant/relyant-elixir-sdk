System.put_env("RELYANT_API_CLIENT_ID", System.get_env("COMPANY_A_API_CLIENT_ID"))
System.put_env("RELYANT_API_CLIENT_SECRET", System.get_env("COMPANY_A_API_CLIENT_SECRET"))
System.put_env("RELYANT_BASE_API_URL", "http://localhost:8000")
# System.put_env("RELYANT_BASE_API_URL", "https://dev.api.relyant.ai")

ExUnit.start()
