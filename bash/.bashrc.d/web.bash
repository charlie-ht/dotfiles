cht_html_template () {
    local name=$1
    cat <<EOF > $name
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<title>Your HTML5 Page...</title>
	<link rel="stylesheet" href="css/style.css">
	<!--[if IE]>
		<script src="http://html5shiv.googlecode.com/svn/trunk/html5.js"></script>
	<![endif]-->
</head>

<body id="home">

	<h1>HTML5 boilerplate</h1>

</body>
</html>
EOF
}
