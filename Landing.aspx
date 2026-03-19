<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Landing.aspx.cs" Inherits="SmarkPark.Landing" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>SmartPark | Welcome</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <style>
        body { 
            background: #1a1a1a; 
            color: #ffffff; 
            font-family: 'Segoe UI', sans-serif;
            margin: 0;
        }
        .navbar { 
            background: rgba(0, 0, 0, 0.9) !important; 
            border-bottom: 1px solid #333;
            padding: 1rem 0;
        }
        .brand-smart { color: #2ecc71; font-weight: bold; }
        .brand-park { color: #ffffff; font-weight: bold; }
        .hero-container {
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            text-align: center;
            background: radial-gradient(circle at center, #2c3e50 0%, #000000 100%);
        }
        .btn-login-top {
            border: 2px solid #2ecc71;
            color: #2ecc71;
            font-weight: 600;
            transition: all 0.3s;
        }
        .btn-login-top:hover {
            background-color: #2ecc71;
            color: #000;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <nav class="navbar navbar-expand-lg navbar-dark fixed-top">
            <div class="container">
                <a class="navbar-brand fs-3" href="#">
                    <span class="brand-smart">Smart</span><span class="brand-park">Park</span>
                </a>
                <div class="ms-auto">
                    <asp:Button ID="btnLogin" runat="server" Text="Login" CssClass="btn btn-login-top px-4" OnClick="RedirectToLogin" />
                </div>
            </div>
        </nav>

        <div class="hero-container">
            <div class="container">
                <h1 class="display-1 fw-bold">
                    <span class="brand-smart">Smart</span><span class="brand-park">Park</span>
                </h1>
                <p class="lead text-secondary mt-3 fs-4">
                    Providing intelligent real-time parking solutions.
                </p>
            </div>
        </div>
    </form>
</body>
</html>