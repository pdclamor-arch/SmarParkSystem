<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UserDashboard.aspx.cs" Inherits="SmartPark.UserDashboard" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <title>SmartPark — User Dashboard</title>
    <link href="https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&family=DM+Sans:wght@400;500;600&display=swap" rel="stylesheet">
    <style>
        :root { --bg: #0a0a0f; --surface: #12121a; --border: #2a2a3e; --accent: #00e5a0; --text: #e8e8f0; --danger: #ff4757; }
        body { background: var(--bg); color: var(--text); font-family: 'DM Sans', sans-serif; margin: 0; }
        header { padding: 0 2rem; height: 60px; border-bottom: 1px solid var(--border); display: flex; align-items: center; justify-content: space-between; background: rgba(10,10,15,0.8); backdrop-filter: blur(10px); position: sticky; top: 0; z-index: 100; }
        .logo { font-family: 'Space Mono'; color: var(--accent); font-weight: 700; text-transform: uppercase; }
        main { display: grid; grid-template-columns: 1fr 400px; height: calc(100vh - 60px); }
        .panel { padding: 2rem; overflow-y: auto; }
        .right-bar { background: rgba(255,255,255,0.02); border-left: 1px solid var(--border); }
        .section-title { font-family: 'Space Mono'; font-size: 11px; color: #6b6b8a; text-transform: uppercase; margin-bottom: 1.5rem; letter-spacing: 1px; }
        
        .spot-card { background: var(--surface); padding: 1.5rem; border-radius: 12px; border: 1px solid var(--border); text-align: center; font-family: 'Space Mono'; cursor: pointer; transition: 0.3s; }
        .spot-card.occupied-now { border-color: #f1c40f; color: #f1c40f; background: rgba(241, 196, 15, 0.05); }
        .spot-card.selected { border-color: var(--accent); background: rgba(0, 229, 160, 0.1); box-shadow: 0 0 15px rgba(0, 229, 160, 0.2); }

        .form-control { width: 100%; background: #1a1a26; border: 1px solid var(--border); color: #fff; padding: 12px; border-radius: 8px; margin: 8px 0; box-sizing: border-box; font-size: 13px; }
        .btn-reserve { width: 100%; padding: 14px; background: var(--accent); border: none; border-radius: 8px; font-weight: 700; cursor: pointer; font-family: 'Space Mono'; margin-top: 10px; color: #0a0a0f; }
        
        .ticket-item { background: #1a1a26; border: 1px solid var(--border); padding: 15px; border-radius: 10px; margin-bottom: 12px; display: flex; justify-content: space-between; align-items: center; }
        .btn-action { background: transparent; border: 1px solid var(--accent); color: var(--accent); padding: 6px 12px; border-radius: 6px; font-size: 10px; cursor: pointer; font-family: 'Space Mono'; margin-left: 5px; }
        
        .modal { position: fixed; inset: 0; background: rgba(0,0,0,0.9); display: flex; align-items: center; justify-content: center; z-index: 1000; }
        .ticket-pop { background: white; color: black; padding: 2rem; border-radius: 24px; text-align: center; width: 320px; box-shadow: 0 25px 50px -12px rgba(0,0,0,0.5); }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:HiddenField ID="hfSelectedSpot" runat="server" />

        <header>
            <div class="logo">SmartPark // User Dashboard</div>
            <div style="font-size: 12px; font-family: 'Space Mono';">
                DRIVER: <span runat="server" id="lblUser" style="color:var(--accent);"></span> 
                | <asp:LinkButton ID="btnLogout" runat="server" OnClick="btnLogout_Click" style="color:var(--danger); text-decoration:none; margin-left:10px;">[EXIT]</asp:LinkButton>
            </div>
        </header>

        <asp:Panel ID="pnlTicket" runat="server" CssClass="modal" Visible="false">
            <div class="ticket-pop">
                <div style="font-family:'Space Mono'; font-size: 10px; color: #999; letter-spacing: 2px;">SECURE DIGITAL PASS</div>
                
                <h1 runat="server" id="modalSpot" style="margin: 10px 0; font-size: 42px; font-family:'Space Mono';"></h1>
                
                <div style="background: #000; color: #00e5a0; padding: 20px; border-radius: 12px; margin: 15px 0; font-family: 'Space Mono'; font-size: 26px; font-weight: bold; letter-spacing: 4px;">
                    <span runat="server" id="modalResID"></span>
                </div>
                
                <div style="text-align: left; font-size: 13px; background: #f8f9fa; padding: 15px; border-radius: 12px; border-left: 4px solid #000;">
                    <p style="margin: 4px 0;"><strong>PLATE:</strong> <span runat="server" id="modalPlate"></span></p>
                    <p style="margin: 4px 0;"><strong>VALID:</strong> <span runat="server" id="modalTime"></span></p>
                </div>
                
                <div style="display: flex; gap: 10px; margin-top: 20px;">
                    <button type="button" onclick="window.print();" style="flex:1; padding:12px; border:1px solid #ddd; border-radius:10px; background:white; font-weight:600; cursor:pointer;">PRINT</button>
                    <asp:Button runat="server" Text="CLOSE" OnClick="btnCloseTicket_Click" style="flex:1; padding:12px; background:black; color:white; border:none; border-radius:10px; font-weight:600; cursor:pointer;" />
                </div>
            </div>
        </asp:Panel>

        <main>
            <div class="panel">
                <div class="section-title">Select Parking Spot</div>
                <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(100px, 1fr)); gap: 15px;">
                    <asp:Repeater ID="rptGrid" runat="server">
                        <ItemTemplate>
                            <div id='<%# Eval("SpotID") %>' 
                                 class='<%# "spot-card " + (Eval("IsOccupied").ToString() == "True" ? "occupied-now" : "") %>' 
                                 onclick='selectSpot("<%# Eval("SpotID") %>")'>
                                <%# Eval("SpotID") %>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>

            <div class="panel right-bar">
                <div class="section-title">Schedule Reservation</div>
                <div class="spot-card" style="text-align:left; cursor:default; background: var(--surface);">
                    <label style="font-size:10px; color: #6b6b8a;">LICENSE PLATE</label>
                    <asp:TextBox ID="txtPlate" runat="server" CssClass="form-control" placeholder="E.G. ABC-1234" />
                    
                    <label style="font-size:10px; color: #6b6b8a;">ENTRY TIME</label>
                    <asp:TextBox ID="txtStart" runat="server" TextMode="DateTimeLocal" CssClass="form-control" />
                    
                    <label style="font-size:10px; color: #6b6b8a;">EXIT TIME</label>
                    <asp:TextBox ID="txtEnd" runat="server" TextMode="DateTimeLocal" CssClass="form-control" />
                    
                    <asp:Button ID="btnReserve" runat="server" Text="GET DIGITAL PASS" CssClass="btn-reserve" OnClick="btnReserve_Click" />
                </div>

                <div class="section-title" style="margin-top:2.5rem;">My Reservations</div>
                <asp:Repeater ID="rptHistory" runat="server" OnItemCommand="rptHistory_ItemCommand">
                    <ItemTemplate>
                        <div class="ticket-item">
                            <div>
                                <strong style="color:var(--accent);"><%# Eval("SpotID") %></strong><br />
                                <small style="font-size:10px; color:#888;"><%# Eval("StartTime", "{0:MMM dd | HH:mm}") %></small>
                            </div>
                            <div>
                                <asp:Button runat="server" CommandName="View" CommandArgument='<%# Eval("ResID") %>' Text="PASS" CssClass="btn-action" />
                                <asp:Button runat="server" CommandName="Delete" CommandArgument='<%# Eval("ResID") %>' 
                                            Text="CANX" CssClass="btn-action" style="border-color:var(--danger); color:var(--danger);" 
                                            OnClientClick="return confirm('Cancel this reservation?');" />
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </main>
    </form>

    <script>
        function selectSpot(spotID) {
            document.querySelectorAll('.spot-card').forEach(card => card.classList.remove('selected'));
            var el = document.getElementById(spotID);
            if(el) el.classList.add('selected');
            document.getElementById('<%= hfSelectedSpot.ClientID %>').value = spotID;
        }
    </script>
</body>
</html>