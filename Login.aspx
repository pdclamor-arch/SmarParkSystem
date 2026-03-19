<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="SmarkPark.Login" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <title>SmartPark — Login</title>
    <link href="https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&family=DM+Sans:wght@300;400;500;600&display=swap" rel="stylesheet">
    <style>
        :root { --bg: #0a0a0f; --surface: #12121a; --border: #2a2a3e; --accent: #00e5a0; --text: #e8e8f0; }
        body { background: var(--bg); color: var(--text); font-family: 'DM Sans', sans-serif; display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100vh; margin: 0; }
        .login-card { background: var(--surface); padding: 2.5rem; border-radius: 15px; border: 1px solid var(--border); width: 100%; max-width: 380px; box-shadow: 0 20px 50px rgba(0,0,0,0.5); }
        .header-title { font-family: 'Space Mono'; font-weight: 700; font-size: 1.5rem; text-align: center; margin-bottom: 2rem; }
        .form-group { margin-bottom: 1.2rem; }
        label { display: block; font-size: 0.75rem; color: #6b6b8a; text-transform: uppercase; margin-bottom: 5px; letter-spacing: 1px; }
        .form-control { width: 100%; background: #1a1a26; border: 1px solid var(--border); color: white; padding: 12px; border-radius: 8px; outline: none; box-sizing: border-box; }
        .form-control:focus { border-color: var(--accent); }
        .btn-action { width: 100%; padding: 12px; background: var(--accent); border: none; border-radius: 8px; font-weight: 700; cursor: pointer; font-family: 'Space Mono'; transition: 0.3s; margin-top: 1rem; }
        .toggle-link { display: block; text-align: center; margin-top: 1.5rem; font-size: 0.85rem; color: var(--accent); text-decoration: none; cursor: pointer; }
        .error-msg { color: #ff4757; font-size: 0.8rem; text-align: center; margin-top: 1rem; display: block; }
        .success-msg { color: var(--accent); font-size: 0.8rem; text-align: center; margin-top: 1rem; display: block; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div style="text-align: center; margin-bottom: 30px;">
            <h1 style="font-size: 3rem; margin: 0;">
                <span style="color: #2ecc71; font-weight: bold;">Smart</span><span style="color: #ffffff; font-weight: bold;">Park</span>
            </h1>
            <div style="margin-top: 10px;">
                <a href="Landing.aspx" style="text-decoration: none; color: #6b6b8a; font-size: 0.9rem;">
                    &larr; Back to Landing Page
                </a>
            </div>
        </div>

        <div class="login-card">
            <asp:Panel ID="pnlLogin" runat="server">
                <div class="header-title">
                    <span style="color: #2ecc71;">Log</span><span style="color: #ffffff;">in</span>
                </div>
                
                <div class="form-group">
                    <label>Username</label>
                    <asp:TextBox ID="txtUser" runat="server" CssClass="form-control" placeholder="Enter username"></asp:TextBox>
                </div>
                <div class="form-group">
                    <label>Password</label>
                    <asp:TextBox ID="txtPass" runat="server" CssClass="form-control" TextMode="Password" placeholder="••••••••"></asp:TextBox>
                </div>
                <asp:Button ID="btnLogin" runat="server" Text="LOG IN" CssClass="btn-action" OnClick="btnLogin_Click" />
                <asp:LinkButton ID="lnkShowRegister" runat="server" CssClass="toggle-link" OnClick="ToggleView">Need an account? Create one</asp:LinkButton>
            </asp:Panel>

            <asp:Panel ID="pnlRegister" runat="server" Visible="false">
                <div class="header-title" style="font-size: 1.2rem;">
                    <span style="color: #2ecc71;">Create</span> <span style="color: #ffffff;">an Account</span>
                </div>

                <div class="form-group">
                    <label>Choose Username</label>
                    <asp:TextBox ID="txtRegUser" runat="server" CssClass="form-control" placeholder="New username"></asp:TextBox>
                </div>
                <div class="form-group">
                    <label>Set Password</label>
                    <asp:TextBox ID="txtRegPass" runat="server" CssClass="form-control" TextMode="Password" placeholder="••••••••"></asp:TextBox>
                </div>
                <asp:Button ID="btnRegister" runat="server" Text="CREATE ACCOUNT" CssClass="btn-action" OnClick="btnRegister_Click" />
                <asp:LinkButton ID="lnkShowLogin" runat="server" CssClass="toggle-link" OnClick="ToggleView">Already have an account? Log in</asp:LinkButton>
            </asp:Panel>
            
            <asp:Label ID="lblStatus" runat="server" CssClass="error-msg" Visible="false"></asp:Label>
        </div>
    </form>
</body>
</html>