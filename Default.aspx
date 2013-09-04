<%@ Page Language="VB"  %>
<%@ Import namespace="System.Configuration" %>
<%@ Import namespace="System.Web.UI" %>
<%@ Import namespace="LinqToTwitter" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head id="Head1" runat="server">
    <title></title> 
    <script runat="server"> 
        Private Const OAuthCredentialsKey As String = "OAuthCredentialsKey"
        Private auth As SignInAuthorizer

        Protected Sub Page_Load(sender As Object, e As EventArgs)
            Dim credentials As IOAuthCredentials = New InMemoryCredentials()
            Dim authString As String = TryCast(Session(OAuthCredentialsKey), String)
            
            If authString Is Nothing Then
                
                lblAuth.Text = ""
                credentials.ConsumerKey = ConfigurationManager.AppSettings("twitterConsumerKey")
                credentials.ConsumerSecret = ConfigurationManager.AppSettings("twitterConsumerSecret")
            Else
                
                lblAuth.Text = authString
                credentials.Load(authString)
                
            End If

            auth = New SignInAuthorizer() With { _
                 .Credentials = credentials, _
                 .PerformRedirect = Sub(authUrl) Response.Redirect(authUrl) _
            }

            If Not Page.IsPostBack Then
                If Not String.IsNullOrWhiteSpace(credentials.ConsumerKey) AndAlso Not String.IsNullOrWhiteSpace(credentials.ConsumerSecret) Then
                    'AuthMultiView.ActiveViewIndex = 1

                    If auth.CompleteAuthorization(Request.Url) Then 
                         
                        ShowData()
                
                        Session(OAuthCredentialsKey) = auth.credentials.ToString()
                    Else
                        lblAuth.Text &= "<br />logged out"
                    End If
                End If
            End If
        End Sub

        Private Sub ShowData()
            lblAuth.Text = ""
            lblAuth.Text &= "<br />OAuthToken: " & auth.Credentials.OAuthToken
            lblAuth.Text &= "<br />AccessToken: " & auth.Credentials.AccessToken
            lblAuth.Text &= "<br />ConsumerKey: " & auth.Credentials.ConsumerKey
            lblAuth.Text &= "<br />ConsumerSecret: " & auth.Credentials.ConsumerSecret
            lblAuth.Text &= "<br />ScreenName: " & auth.Credentials.ScreenName
            lblAuth.Text &= "<br />UserId: " & auth.Credentials.UserId
            
            If auth.Credentials.OAuthToken <> "" Then
                Dim ctx = New TwitterContext(auth)
                'Dim tweet = ctx.UpdateStatus("Testing LINQ to Twitter at " & Date.Now.ToString)
                'lblTest.Text = "Status returned: (" & tweet.StatusID & ") " & tweet.User.Name & ", " & tweet.Text
                
                Dim search =
                  (From srch In ctx.Search
                   Where srch.Type = LinqToTwitter.SearchType.Search AndAlso
                         srch.Query = "mudrunfun") _
                  .SingleOrDefault()

                TwitterListView.DataSource = search.Statuses
                TwitterListView.DataBind()
            End If
        End Sub
        
        Protected Sub signInButton_Click(sender As Object, e As EventArgs) Handles signInButton.Click
            'forceLogin:
            auth.BeginAuthorization(Request.Url, True)
        End Sub
    </script>
</head>
<body>
    <form id="Form1" runat="server">
        <asp:Label ID="lblAuth" runat="server" Text="Label"></asp:Label><br /><br /> 
        <asp:Button ID="signInButton" runat="server" Text="Sign In" /><br /><br />

        <asp:ListView ID="TwitterListView" runat="server">
		<LayoutTemplate>
			<table id="Table1" runat="server">
				<tr id="Tr1" runat="server">
					<th>Picture </th>
					<th>Name </th>
					<th>Last Tweet </th>
				</tr>
				<tr id="itemPlaceholder">
				</tr>
			</table>
		</LayoutTemplate>
		<ItemTemplate>
			<tr id="Tr2" runat="server">
				<td>
					<asp:Image ID="UserImage" runat="server" ImageUrl='<%#Eval("User.ProfileImageUrl") %>' />
				</td>
				<td><asp:Label ID="NameLabel" runat="server" Text='<%#Eval("User.Name") %>' /> </td>
				<td><asp:Label ID="TweetLabel" runat="server" Text='<%#Eval("Text") %>' /> </td>
			</tr>
		</ItemTemplate>
	</asp:ListView>
	 </form>
</body>
</html>
