using System;
using System.Web.UI;

namespace SmarkPark
{
    public partial class Landing : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void RedirectToLogin(object sender, EventArgs e)
        {
            Response.Redirect("Login.aspx");
        }
    }
}