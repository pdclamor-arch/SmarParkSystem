using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Web.UI.WebControls;

namespace SmartPark
{
    public partial class UserDashboard : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["SmartParkDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["Username"] == null) Response.Redirect("Login.aspx");
            lblUser.InnerText = Session["Username"].ToString().ToUpper();

            if (!IsPostBack)
            {
                LoadGrid();
                LoadTickets();
            }
        }

        private void LoadGrid()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                SqlDataAdapter da = new SqlDataAdapter("SELECT SpotID, IsOccupied FROM ParkingSpots ORDER BY SpotID ASC", conn);
                DataTable dt = new DataTable();
                da.Fill(dt);
                rptGrid.DataSource = dt;
                rptGrid.DataBind();
            }
        }

        private void LoadTickets()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = "SELECT * FROM Reservations WHERE UserID = @u ORDER BY StartTime DESC";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@u", Session["UserID"]);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                rptHistory.DataSource = dt;
                rptHistory.DataBind();
            }
        }

        private string GenerateRandomCode(int length)
        {
            const string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
            Random random = new Random();
            return new string(Enumerable.Repeat(chars, length)
                .Select(s => s[random.Next(s.Length)]).ToArray());
        }

        protected void btnReserve_Click(object sender, EventArgs e)
        {
            DateTime start, end;
            if (!DateTime.TryParse(txtStart.Text, out start) || !DateTime.TryParse(txtEnd.Text, out end))
            {
                Alert("Invalid Date Format.");
                return;
            }

            if (start < DateTime.Now) { Alert("Cannot reserve in the past."); return; }
            if (end <= start) { Alert("End time must be after start time."); return; }
            if (string.IsNullOrEmpty(hfSelectedSpot.Value)) { Alert("Please select a spot."); return; }

            int sid = Convert.ToInt32(hfSelectedSpot.Value);

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                string checkSql = @"SELECT COUNT(*) FROM Reservations 
                            WHERE SpotID = @sid 
                            AND @start < EndTime 
                            AND @end > StartTime";

                using (SqlCommand cmdCheck = new SqlCommand(checkSql, conn))
                {
                    cmdCheck.Parameters.AddWithValue("@sid", sid);
                    cmdCheck.Parameters.AddWithValue("@start", start);
                    cmdCheck.Parameters.AddWithValue("@end", end);

                    int existingCount = (int)cmdCheck.ExecuteScalar();

                    if (existingCount > 0)
                    {
                        Alert("This spot is already reserved for the selected timeframe. Please choose a different time or spot.");
                        return;
                    }
                }

                SqlTransaction trans = conn.BeginTransaction();
                try
                {
                    string sql = "INSERT INTO Reservations (UserID, SpotID, StartTime, EndTime, TicketCode, Plate) VALUES (@uid, @sid, @s, @e, @c, @p)";
                    SqlCommand cmd = new SqlCommand(sql, conn, trans);
                    cmd.Parameters.AddWithValue("@uid", Session["UserID"]);
                    cmd.Parameters.AddWithValue("@sid", sid);
                    cmd.Parameters.AddWithValue("@s", start);
                    cmd.Parameters.AddWithValue("@e", end);
                    cmd.Parameters.AddWithValue("@c", Guid.NewGuid().ToString().Substring(0, 8).ToUpper());
                    cmd.Parameters.AddWithValue("@p", txtPlate.Text);
                    cmd.ExecuteNonQuery();

                    if (start <= DateTime.Now.AddMinutes(5))
                    {
                        new SqlCommand($"UPDATE ParkingSpots SET IsOccupied=1 WHERE SpotID={sid}", conn, trans).ExecuteNonQuery();
                    }

                    trans.Commit();
                    LoadGrid();
                    LoadTickets();
                    Alert("Reservation Confirmed!");
                }
                catch (Exception ex)
                {
                    trans.Rollback();
                    Alert("Error: " + ex.Message);
                }
            }
        }

        protected void rptHistory_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            string resID = e.CommandArgument.ToString();

            if (e.CommandName == "View")
            {
                ShowPass(resID);
            }
            else if (e.CommandName == "Delete")
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();
                    SqlCommand cmdGetSpot = new SqlCommand("SELECT SpotID FROM Reservations WHERE ResID = @rid", conn);
                    cmdGetSpot.Parameters.AddWithValue("@rid", resID);
                    object spotObj = cmdGetSpot.ExecuteScalar();

                    if (spotObj != null)
                    {
                        int spotID = Convert.ToInt32(spotObj);
                        SqlTransaction trans = conn.BeginTransaction();
                        try
                        {
                            SqlCommand cmdDel = new SqlCommand("DELETE FROM Reservations WHERE ResID = @rid", conn, trans);
                            cmdDel.Parameters.AddWithValue("@rid", resID);
                            cmdDel.ExecuteNonQuery();

                            SqlCommand cmdFree = new SqlCommand("UPDATE ParkingSpots SET IsOccupied = 0 WHERE SpotID = @sid", conn, trans);
                            cmdFree.Parameters.AddWithValue("@sid", spotID);
                            cmdFree.ExecuteNonQuery();

                            trans.Commit();
                        }
                        catch { trans.Rollback(); }
                    }
                }
                LoadTickets();
                LoadGrid();
            }
        }

        private void ShowPass(string resID)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = "SELECT ResID, SpotID, Plate, StartTime, EndTime, TicketCode FROM Reservations WHERE ResID = @id";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@id", resID);

                conn.Open();
                SqlDataReader rdr = cmd.ExecuteReader();

                if (rdr.Read())
                {
                    modalSpot.InnerText = rdr["SpotID"].ToString();
                    modalPlate.InnerText = rdr["Plate"].ToString();

                    DateTime start = Convert.ToDateTime(rdr["StartTime"]);
                    DateTime end = Convert.ToDateTime(rdr["EndTime"]);
                    modalTime.InnerText = $"{start:MMM dd, HH:mm} - {end:HH:mm}";

                    modalResID.InnerText = rdr["TicketCode"].ToString();

                    pnlTicket.Visible = true;

                }
                else
                {
                    Alert("Ticket details not found.");
                }
            }
        }

        private void Alert(string msg)
        {
            ClientScript.RegisterStartupScript(this.GetType(), "alert", $"alert('{msg}');", true);
        }

        protected void btnCloseTicket_Click(object sender, EventArgs e) { pnlTicket.Visible = false; }
        protected void btnLogout_Click(object sender, EventArgs e) { Session.Abandon(); Response.Redirect("Login.aspx"); }
    }
}