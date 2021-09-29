<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <!-- <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0"> -->
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Login</title>
    <link rel="stylesheet" href="static/css/phone.css">
    <link rel="stylesheet" href="static/css/font-awesome.min.css">
</head>
<body>
    <div id="wrapper">
        <!---------Login-------------------------------------------->
        <form action="index.php" method="get">
            <div >
                <input id="toField" type="text" name="host" placeholder="Host" value="<?= $_SERVER['HTTP_HOST'] ?>" />
                <input id="toField" type="text" name="user" placeholder="Usuario" />
                <input id="toField" type="password" name="pass" placeholder="Contraseña" />
            </div>
            <div >
                <input id="login"  class="fa fa-user" type="submit" value="Ingresar">
            </div>
        </form>
    </div>
</body>
</html>