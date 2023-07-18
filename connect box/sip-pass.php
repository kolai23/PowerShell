<html lang="ru">
    <head>
        <title>SIP password changer</title>
        <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
    </head>

<body>

<?php 

$authuser = $_SERVER['AUTH_USER'];
$authuser = str_replace('CAPITAL\\', '', $authuser);

// echo 'Authuser: ' . $authuser;

$ldap_columns = NULL;
$ldap_connection = NULL;
$ldap_password = 'eo5iR:ooceiD';
$ldap_username = 'ext.asterisk@capital.local';
//------------------------------------------------------------------------------
// Connect to the LDAP server.
//------------------------------------------------------------------------------
$ldap_connection = ldap_connect('srvlt40');
if (FALSE === $ldap_connection){
    die("<p>Failed to connect to the LDAP server!</p>");
}
ldap_set_option($ldap_connection, LDAP_OPT_PROTOCOL_VERSION, 3) or die('Unable to set LDAP protocol version');
ldap_set_option($ldap_connection, LDAP_OPT_REFERRALS, 0); // We need this for doing an LDAP search.

if (TRUE !== ldap_bind($ldap_connection, $ldap_username, $ldap_password)){
    die('<p>Failed to bind to LDAP server.</p>');
}
$ldap_base_dn = 'DC=capital,DC=local';

// Set sip password if sended by POST

if (isset($_POST["pass"])) {
		
		$search_filter1 = "(&(objectCategory=person)(objectClass=user)(SamAccountName=".$authuser."))";
		$result1 = ldap_search($ldap_connection, $ldap_base_dn, $search_filter1);
		$entries = ldap_get_entries($ldap_connection, $result1);
		$count1 = intval( $entries['count'] );
		
	            if( $count1 > 0 )
	            {
					
					$entry1 = array('sippassword'=>$_POST["pass"]);
	        		if( !ldap_mod_replace( $ldap_connection, $entries[0]['dn'], $entry1 ) )
    					echo ldap_error( $ldap_connection );
				
				
				//echo 'For user <b>'.$authuser.'</b> password changed to <b>'.$_POST["pass"].'</b>';
				//echo $entries[0]['dn'];
				
	            }

		
}

// Get sip password

$search_filter = "(&(objectCategory=person)(SamAccountName=".$authuser.")(!(userAccountControl:1.2.840.113556.1.4.803:=2)))";
$result = ldap_search($ldap_connection, $ldap_base_dn, $search_filter);

if (FALSE !== $result){
    $entries = ldap_get_entries($ldap_connection, $result);
	$count = intval( $entries['count'] );

    if ($count > 0){
        $odd = 0;

		$ldap_columns = array(
			"sippassword",
			);

        for ($i = 0; $i < $entries['count']; $i++){
            $td_count = 0;
            foreach ($ldap_columns AS $col_name){
                if (0 === $td_count++){
                    echo '';
                }else{
                    echo '';
                }
                if (isset($entries[$i][$col_name])){
                    $sippwd = NULL;
                    if ('sippassword' === $col_name){
                        $sippwd = $entries[$i][$col_name][0];
                    }else{
                        $sippwd = '';
                    }
                }
            }
        }
    }
}
ldap_unbind($ldap_connection); // Clean up after ourselves.

echo '<div align="left"><a href="/sip-pass.php">RU</a> / <a href="/sip-pass-en.php">EN</a></div><div align="center">
Ваш текущий пароль к Zoiper: <b>' . $sippwd . '</b> <br><br>

				<form action="sip-pass.php" method="post">
					Изменить пароль на <input type="text" class="" style="width:150px;" placeholder="Введите новый пароль..." value="" pattern="(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,}" name="pass">
					<input type="submit" class="" style="" value="Применить">
				</form>
Пароль должен включать в себя:<br>
- буквы только английского языка<br>
- минимальная длина пароля 8 символов<br>
- минимум одна строчная буква<br>
- минимум одна заглавная буква<br>
-минимум одна цифра
</div>

</body>
</html>';

?>