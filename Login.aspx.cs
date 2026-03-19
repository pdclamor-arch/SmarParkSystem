using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web;

namespace SmarkPark
{
    public partial class Login : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["SmartParkDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Session.Clear();
            }
        }

        protected void ToggleView(object sender, EventArgs e)
        {
            pnlLogin.Visible = !pnlLogin.Visible;
            pnlRegister.Visible = !pnlRegister.Visible;
            lblStatus.Visible = false;
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = "SELECT UserID, Username, [Role] FROM Users WHERE Username = @u AND Password = @p";
                SqlCommand cmd = new SqlCommand(sql, conn);

                cmd.Parameters.AddWithValue("@u", txtUser.Text.Trim());
                cmd.Parameters.AddWithValue("@p", txtPass.Text.Trim());

                try
                {
                    conn.Open();
                    SqlDataReader dr = cmd.ExecuteReader();

                    if (dr.Read())
                    {
                        Session["UserID"] = dr["UserID"];
                        Session["Username"] = dr["Username"].ToString();

                        string role = dr["Role"].ToString().Trim();
                        Session["Role"] = role;

                        if (role.Equals("Admin", StringComparison.OrdinalIgnoreCase))
                        {
                            Response.Redirect("AdminDashboard.aspx");
                        }
                        else
                        {
                            Response.Redirect("UserDashboard.aspx");
                        }
                    }
                    else
                    {
                        lblStatus.Visible = true;
                        lblStatus.Text = "Invalid Username or Password.";
                        lblStatus.ForeColor = System.Drawing.Color.Red;
                    }
                }
                catch (Exception ex)
                {
                    lblStatus.Visible = true;
                    lblStatus.Text = "Database Error: " + ex.Message;
                }
            }
        }

        protected void btnRegister_Click(object sender, EventArgs e)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                // Check if user exists
                string checkSql = "SELECT COUNT(*) FROM Users WHERE Username = @u";
                SqlCommand checkCmd = new SqlCommand(checkSql, conn);
                checkCmd.Parameters.AddWithValue("@u", txtRegUser.Text.Trim());

                conn.Open();
                int count = (int)checkCmd.ExecuteScalar();

                if (count > 0)
                {
                    lblStatus.Visible = true;
                    lblStatus.Text = "Username already taken.";
                    lblStatus.ForeColor = System.Drawing.Color.Red;
                    return;
                }

                // Insert new user with default 'User' role
                string sql = "INSERT INTO Users (Username, Password, [Role]) VALUES (@u, @p, 'User')";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@u", txtRegUser.Text.Trim());
                cmd.Parameters.AddWithValue("@p", txtRegPass.Text.Trim());

                cmd.ExecuteNonQuery();

                lblStatus.Visible = true;
                lblStatus.Text = "Account created! You can now log in.";
                lblStatus.ForeColor = System.Drawing.Color.Green;

                // Switch back to Login view
                pnlLogin.Visible = true;
                pnlRegister.Visible = false;
            }
        }
    }
}