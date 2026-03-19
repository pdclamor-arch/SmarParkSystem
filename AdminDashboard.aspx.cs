using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;

namespace SmartPark
{
    public partial class AdminDashboard : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["SmartParkDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
  
            if (Session["Role"] == null || !Session["Role"].ToString().Equals("Admin", StringComparison.OrdinalIgnoreCase))
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadAll();
            }
        }

        private void LoadAll()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {

                SqlDataAdapter daSpots = new SqlDataAdapter("SELECT * FROM ParkingSpots ORDER BY SpotID ASC", conn);
                DataTable dtGrid = new DataTable();
                daSpots.Fill(dtGrid);
                rptGrid.DataSource = dtGrid;
                rptGrid.DataBind();
                gvSpots.DataSource = dtGrid;
                gvSpots.DataBind();

                SqlDataAdapter daUsers = new SqlDataAdapter("SELECT UserID, Username, Password, [Role] FROM Users", conn);
                DataTable dtUsers = new DataTable();
                daUsers.Fill(dtUsers);
                gvUsers.DataSource = dtUsers;
                gvUsers.DataBind();

                string resSql = @"SELECT r.*, u.Username 
                                  FROM Reservations r 
                                  INNER JOIN Users u ON r.UserID = u.UserID 
                                  ORDER BY r.ResID DESC";

                SqlDataAdapter daRes = new SqlDataAdapter(resSql, conn);
                DataTable dtRes = new DataTable();
                daRes.Fill(dtRes);

                gvReservations.DataSource = dtRes;
                gvReservations.DataBind();
                rptRes.DataSource = dtRes;
                rptRes.DataBind();
            }
        }

        protected void gvUsers_RowEditing(object sender, GridViewEditEventArgs e)
        {
            gvUsers.EditIndex = e.NewEditIndex;
            LoadAll();
        }

        protected void gvUsers_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            gvUsers.EditIndex = -1;
            LoadAll();
        }

        protected void gvUsers_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            int userId = Convert.ToInt32(gvUsers.DataKeys[e.RowIndex].Value);
            GridViewRow row = gvUsers.Rows[e.RowIndex];

            string user = ((TextBox)row.FindControl("txtUsername")).Text;
            string pass = ((TextBox)row.FindControl("txtPassword")).Text;
            string role = ((DropDownList)row.FindControl("ddlRole")).SelectedValue;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = "UPDATE Users SET Username=@u, Password=@p, [Role]=@r WHERE UserID=@id";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@u", user);
                cmd.Parameters.AddWithValue("@p", pass);
                cmd.Parameters.AddWithValue("@r", role);
                cmd.Parameters.AddWithValue("@id", userId);
                conn.Open();
                cmd.ExecuteNonQuery();
            }

            gvUsers.EditIndex = -1;
            LoadAll();
        }

        protected void gvUsers_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            int userId = Convert.ToInt32(gvUsers.DataKeys[e.RowIndex].Value);
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                SqlCommand cmd = new SqlCommand("DELETE FROM Users WHERE UserID=@id", conn);
                cmd.Parameters.AddWithValue("@id", userId);
                conn.Open();
                cmd.ExecuteNonQuery();
            }
            LoadAll();
        }

        protected void btnAddSpot_Click(object sender, EventArgs e)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                string findGapSql = @"SELECT MIN(t1.SpotID + 1) FROM ParkingSpots t1 
                              LEFT JOIN ParkingSpots t2 ON t1.SpotID + 1 = t2.SpotID 
                              WHERE t2.SpotID IS NULL";
                SqlCommand cmdGap = new SqlCommand(findGapSql, conn);
                object result = cmdGap.ExecuteScalar();
                int nextId = (result == DBNull.Value) ? 1 : Convert.ToInt32(result);

                SqlCommand cmdEnable = new SqlCommand("SET IDENTITY_INSERT ParkingSpots ON", conn);
                cmdEnable.ExecuteNonQuery();

                try
                {
                    string insertSql = "INSERT INTO ParkingSpots (SpotID, IsOccupied) VALUES (@id, 0)";
                    using (SqlCommand cmdInsert = new SqlCommand(insertSql, conn))
                    {
                        cmdInsert.Parameters.AddWithValue("@id", nextId);
                        cmdInsert.ExecuteNonQuery();
                    }
                }
                finally
                {
                    SqlCommand cmdDisable = new SqlCommand("SET IDENTITY_INSERT ParkingSpots OFF", conn);
                    cmdDisable.ExecuteNonQuery();
                }
            }
            LoadAll();
        }

        protected void btnRemoveSpot_Click(object sender, EventArgs e)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                string sql = @"DELETE FROM ParkingSpots WHERE SpotID = (SELECT TOP 1 SpotID FROM ParkingSpots WHERE IsOccupied = 0 ORDER BY SpotID DESC)";
                int rows = new SqlCommand(sql, conn).ExecuteNonQuery();
                if (rows == 0) ClientScript.RegisterStartupScript(this.GetType(), "alert", "alert('No available spots to remove.');", true);
            }
            LoadAll();
        }

        protected void rptRes_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Kick")
            {
                string[] args = e.CommandArgument.ToString().Split('|');
                string resID = args[0];
                string spotID = args[1];

                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();
                    SqlTransaction trans = conn.BeginTransaction();
                    try
                    {
                        SqlCommand cmdDel = new SqlCommand("DELETE FROM Reservations WHERE ResID = @rid", conn, trans);
                        cmdDel.Parameters.AddWithValue("@rid", resID);
                        cmdDel.ExecuteNonQuery();

                        SqlCommand cmdUpdate = new SqlCommand("UPDATE ParkingSpots SET IsOccupied = 0 WHERE SpotID = @sid", conn, trans);
                        cmdUpdate.Parameters.AddWithValue("@sid", spotID);
                        cmdUpdate.ExecuteNonQuery();

                        trans.Commit();
                    }
                    catch
                    {
                        trans.Rollback();
                    }
                }
                LoadAll();
            }
        }

        protected void gvSpots_RowEditing(object sender, GridViewEditEventArgs e) { gvSpots.EditIndex = e.NewEditIndex; LoadAll(); }
        protected void gvSpots_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e) { gvSpots.EditIndex = -1; LoadAll(); }

        protected void gvSpots_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            int sid = Convert.ToInt32(gvSpots.DataKeys[e.RowIndex].Value);
            string status = ((DropDownList)gvSpots.Rows[e.RowIndex].FindControl("ddlStatus")).SelectedValue;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                SqlCommand cmd = new SqlCommand("UPDATE ParkingSpots SET IsOccupied=@s WHERE SpotID=@id", conn);
                cmd.Parameters.AddWithValue("@s", status);
                cmd.Parameters.AddWithValue("@id", sid);
                conn.Open();
                cmd.ExecuteNonQuery();
            }
            gvSpots.EditIndex = -1;
            LoadAll();
        }

        protected void gvSpots_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            int sid = Convert.ToInt32(gvSpots.DataKeys[e.RowIndex].Value);
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                SqlCommand cmd = new SqlCommand("DELETE FROM ParkingSpots WHERE SpotID=@id", conn);
                cmd.Parameters.AddWithValue("@id", sid);
                conn.Open();
                try { cmd.ExecuteNonQuery(); }
                catch { /* Handle foreign key constraint if spot has reservation */ }
            }
            LoadAll();
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }
    }
}