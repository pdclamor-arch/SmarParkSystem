<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminDashboard.aspx.cs" Inherits="SmartPark.AdminDashboard" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <title>SmartPark Admin — Command Center</title>
    <link href="https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&family=DM+Sans:wght@400;500;600&display=swap" rel="stylesheet">
    <style>
        :root { --bg: #0a0a0f; --surface: #12121a; --border: #2a2a3e; --accent: #7c6bff; --text: #e8e8f0; --danger: #ff4757; --success: #00e5a0; }
        body { background: var(--bg); color: var(--text); font-family: 'DM Sans', sans-serif; margin: 0; }      
        header { padding: 0 2rem; height: 60px; border-bottom: 1px solid var(--border); display: flex; align-items: center; justify-content: space-between; background: rgba(10,10,15,0.8); backdrop-filter: blur(10px); position: sticky; top: 0; z-index: 100; }
        .logo { font-family: 'Space Mono'; color: var(--accent); font-weight: 700; text-transform: uppercase; }
        main { display: grid; grid-template-columns: 1fr 400px; height: calc(100vh - 60px); }
        .panel { padding: 2rem; overflow-y: auto; }
        .right-bar { background: rgba(255,255,255,0.01); border-left: 1px solid var(--border); }
        .section-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem; }
        .btn-mgmt { background: #1a1a26; border: 1px solid var(--border); color: #fff; padding: 6px 12px; border-radius: 6px; cursor: pointer; font-family: 'Space Mono'; font-size: 10px; transition: 0.3s; text-decoration: none; display: inline-block; }
        .btn-mgmt:hover { border-color: var(--accent); color: var(--accent); }
        .admin-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(60px, 1fr)); gap: 8px; margin-bottom: 2rem; }
        .spot-node { height: 35px; border: 1px solid var(--border); border-radius: 4px; display: flex; align-items: center; justify-content: center; font-family: 'Space Mono'; font-size: 10px; transition: 0.3s; }
        .spot-node.occupied { border-color: var(--danger); color: var(--danger); background: rgba(255, 71, 87, 0.1); }
        .spot-node.free { border-color: var(--success); color: var(--success); background: rgba(0, 229, 160, 0.05); }
        .table-container { display: grid; grid-template-columns: 1.2fr 0.8fr; gap: 20px; margin-top: 1rem; }
        .table-card { background: var(--surface); border: 1px solid var(--border); border-radius: 8px; padding: 1rem; overflow-x: auto; }
        .gv-style { width: 100%; border-collapse: collapse; font-size: 11px; }
        .gv-style th { text-align: left; color: #6b6b8a; padding: 10px; border-bottom: 1px solid var(--border); text-transform: uppercase; font-size: 9px; letter-spacing: 0.5px; }
        .gv-style td { padding: 10px; border-bottom: 1px solid #1a1a26; }
        .status-pill { padding: 2px 6px; border-radius: 4px; font-size: 9px; font-weight: bold; text-transform: uppercase; }
        .pill-occupied { background: rgba(255, 71, 87, 0.2); color: var(--danger); }
        .pill-free { background: rgba(0, 229, 160, 0.2); color: var(--success); }
        .edit-input { background: #0a0a0f; border: 1px solid var(--accent); color: white; padding: 4px; border-radius: 4px; width: 90%; font-size: 11px; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <header>
            <div class="logo">SmartPark // Admin Terminal</div>
            <asp:LinkButton ID="btnLogout" runat="server" OnClick="btnLogout_Click" style="color:var(--danger); text-decoration:none; font-size:12px; font-family:'Space Mono';">LOGOUT</asp:LinkButton>
        </header>

        <main>
            <div class="panel">
                <div class="section-header">
                    <h4 style="margin:0; font-family:'Space Mono'; font-size: 14px;">Parking Spot Layout Management</h4>
                    <div>
                        <asp:Button ID="btnAddSpot" runat="server" Text="+ NEW SPOT" CssClass="btn-mgmt" OnClick="btnAddSpot_Click" />
                        <asp:Button ID="btnRemoveSpot" runat="server" Text="- REMOVE LAST" CssClass="btn-mgmt" OnClick="btnRemoveSpot_Click" />
                    </div>
                </div>

                <div class="admin-grid">
                    <asp:Repeater ID="rptGrid" runat="server">
                        <ItemTemplate>
                            <div class='<%# "spot-node " + (Eval("IsOccupied").ToString() == "True" ? "occupied" : "free") %>'>
                                <%# Eval("SpotID") %>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <div class="table-container">
                    <div>
                        <h4 style="font-family:'Space Mono'; font-size: 12px; margin-bottom: 0.5rem;">User Master Control (Edit/Delete)</h4>
                        <div class="table-card">
                            <asp:GridView ID="gvUsers" runat="server" AutoGenerateColumns="False" CssClass="gv-style" GridLines="None"
                                DataKeyNames="UserID" OnRowEditing="gvUsers_RowEditing" OnRowCancelingEdit="gvUsers_RowCancelingEdit" 
                                OnRowUpdating="gvUsers_RowUpdating" OnRowDeleting="gvUsers_RowDeleting">
                                <Columns>
                                    <asp:BoundField DataField="UserID" HeaderText="ID" ReadOnly="true" ItemStyle-Width="30px" />
                                    
                                    <asp:TemplateField HeaderText="User">
                                        <ItemTemplate><%# Eval("Username") %></ItemTemplate>
                                        <EditItemTemplate>
                                            <asp:TextBox ID="txtUsername" runat="server" Text='<%# Bind("Username") %>' CssClass="edit-input" />
                                        </EditItemTemplate>
                                    </asp:TemplateField>

                                    <asp:TemplateField HeaderText="Password">
                                        <ItemTemplate><%# Eval("Password") %></ItemTemplate>
                                        <EditItemTemplate>
                                            <asp:TextBox ID="txtPassword" runat="server" Text='<%# Bind("Password") %>' CssClass="edit-input" />
                                        </EditItemTemplate>
                                    </asp:TemplateField>

                                    <asp:TemplateField HeaderText="Role">
                                        <ItemTemplate><%# Eval("Role") %></ItemTemplate>
                                        <EditItemTemplate>
                                            <asp:DropDownList ID="ddlRole" runat="server" CssClass="edit-input" SelectedValue='<%# Bind("Role") %>'>
                                                <asp:ListItem>User</asp:ListItem>
                                                <asp:ListItem>Admin</asp:ListItem>
                                            </asp:DropDownList>
                                        </EditItemTemplate>
                                    </asp:TemplateField>

                                    <asp:CommandField ShowEditButton="True" ShowDeleteButton="True" 
                                        ButtonType="Button" ControlStyle-CssClass="btn-mgmt" 
                                        EditText="EDIT" DeleteText="DEL" UpdateText="SAVE" CancelText="ESC" />
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>

                    <div>
                        <h4 style="font-family:'Space Mono'; font-size: 12px; margin-bottom: 0.5rem;">Spot Vacancy</h4>
                        <div class="table-card">
                            <asp:GridView ID="gvSpots" runat="server" AutoGenerateColumns="False" CssClass="gv-style" GridLines="None">
                                <Columns>
                                    <asp:BoundField DataField="SpotID" HeaderText="Spot ID" />
                                    <asp:TemplateField HeaderText="Status">
                                        <ItemTemplate>
                                            <span class='<%# Eval("IsOccupied").ToString() == "True" ? "status-pill pill-occupied" : "status-pill pill-free" %>'>
                                                <%# Eval("IsOccupied").ToString() == "True" ? "Occupied" : "Available" %>
                                            </span>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>
                </div>

                <h4 style="font-family:'Space Mono'; font-size: 12px; margin: 2rem 0 0.5rem 0;">Reservation History</h4>
<div class="table-card">
    <asp:GridView ID="gvReservations" runat="server" AutoGenerateColumns="False" CssClass="gv-style" GridLines="None">
        <Columns>
            <asp:BoundField DataField="ResID" HeaderText="ID" />
            
            <asp:TemplateField HeaderText="Digital Pass">
                <ItemTemplate>
                    <span style="font-family: 'Space Mono'; color: #00e5a0; background: #000; padding: 4px 8px; border-radius: 4px; font-weight: bold; border: 1px solid #2a2a3e;">
                        <%# Eval("TicketCode") %>
                    </span>
                </ItemTemplate>
            </asp:TemplateField>

            <asp:BoundField DataField="SpotID" HeaderText="Spot" />
            <asp:BoundField DataField="Username" HeaderText="Driver" />
            <asp:BoundField DataField="Plate" HeaderText="Plate" />
            <asp:BoundField DataField="StartTime" HeaderText="Start" DataFormatString="{0:MMM dd HH:mm}" />
            <asp:BoundField DataField="EndTime" HeaderText="End" DataFormatString="{0:MMM dd HH:mm}" />
        </Columns>
    </asp:GridView>
</div>
            </div>

            <div class="panel right-bar">
                <h4 style="margin:0 0 1.5rem 0; font-family:'Space Mono'; font-size: 14px;">Live Actions</h4>
                <asp:Repeater ID="rptRes" runat="server" OnItemCommand="rptRes_ItemCommand">
                    <ItemTemplate>
                        <div class="table-card" style="border-left: 3px solid var(--danger); margin-bottom: 12px; background: #1a1a26;">
                            <div style="display:flex; justify-content:space-between; align-items:center;">
                                <strong style="color:var(--danger); font-size: 14px;"><%# Eval("SpotID") %></strong>
                                <asp:Button runat="server" CommandName="Kick" CommandArgument='<%# Eval("ResID") + "|" + Eval("SpotID") %>' Text="FORCE CLEAR" style="background:transparent; border:1px solid var(--danger); color:var(--danger); padding:4px 8px; border-radius:4px; font-size:9px; cursor:pointer;" />
                            </div>
                            <div style="font-size: 11px; margin-top: 5px;">
                                <div>Driver: <%# Eval("Username") %></div>
                                <div style="color:#6b6b8a; font-family:'Space Mono';"><%# Eval("Plate") %></div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </main>
    </form>
</body>
</html>