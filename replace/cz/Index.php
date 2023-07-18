<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<title>Mail Forwarding</title>
</head>
<style>
	body {	
 	font-family: Arial, "Helvetica Neue", Helvetica, sans-serif;	
 	}	

   p.dline {
    padding: 10px;
   }
	p.next {
    text-indent: 50px; /* Отступ первой строки в пикселах */
   }
   ul {
    list-style: none;
}

ul li:before {
    content:  "—";
    position: relative;
    left:     -5px;
}
</style>
<body>

 <form  action="index.php" method="post" >

    <table width="25%" cellspacing="0" cellpadding="4" align="center">
    <tr> 
    <td align="right">Iniciátor přesměrovaní</td>
    <td><input type="text" name="initiator" id="initiator" maxlength="60" value="<?php echo $_SERVER['AUTH_USER'] ?>" size="21"></td>
    </tr>
    <tr> 
     <td align="right">Objednatel</td>
     <td>
	<?php
		$string=$_SERVER['AUTH_USER'];
		$string = str_replace('CAPITAL\\', '', $string);
		$string_txt= $string.".txt";
			if(file_exists("c:/inetpub/Redirects/Managers/$string_txt")) {	
				$file = file("c:/inetpub/Redirects/Managers/$string_txt");
				echo '<select name="sender">';
				foreach($file as $key=>$value){
				echo '<option>'.$value.'</option>';
				}
				echo '</select>';
			} else {
			echo '<input type="text" name="sender" readonly="true" id="sender" maxlength="60" value='.$string.' size="21">';
			}		
	?>
	</td>
    </tr>
    <tr> 
    <td align="right">Příjemce</td>
    <td>
	<?php
	//if(file_exists("Managers/$string_txt")) {
	//echo '<select name="recipient">';
	//foreach($file as $key=>$value){
	//echo '<option>'.$value.'</option>';
	//}
	//echo '</select>';
	//} else {
		$file = file("c:/inetpub/Redirects/Managers/users.txt");
		echo '<select name="recipient">';
		foreach($file as $key=>$value){
		echo '<option>'.$value.'</option>';
		}
	//}
	?>
	</td>
    </tr>
    <td></td>
    <td><input type="submit" name="set" id="set" value="Nastavit přesměrovaní " style="height: 22px; width: 180px"></td>
    </tr>
	<td></td>
     <td><input type="submit" name="clear" id="clear" value="Zrušit přesměrovaní" style="height: 22px; width: 180px"></td>
    </tr>
   </table>
  </form>



<?php

if(isset($_POST["set"]) and (!(empty($_POST["sender"]))))
{	
	//создаем объект DateTime с текущей датой
	$date = date_create();
	//определяем имя файла
	$file_name =$string. "_" .date_format($date, 'sidmY') . ".txt";
	// Открыть текстовый файл
	$f = fopen("C:\\inetpub\\Redirects\\Requests\\".$file_name, "w+");
	fwrite($f,$string."\r\n".$_POST['sender']."\r\n".$_POST["recipient"]."\r\n"."set"."\r\n"); 
	fclose($f);
	echo '<b><p align="center"; style="color:green;">Žádost byla přijatá!</style></b>';
	}  else if(isset($_POST["clear"]))
{	

	//создаем объект DateTime с текущей датой
	$date = date_create();
	//определяем имя файла
	$file_name =$string. "_" .date_format($date, 'sidmY') . ".txt";
	// Открыть текстовый файл
	$f = fopen("C:\\inetpub\\Redirects\\Requests\\".$file_name, "w+");
	fwrite($f,$string."\r\n".$_POST['sender']."\r\n".$_POST["recipient"]."\r\n"."clear"."\r\n"); 
	fclose($f);
	echo '<b><p align="center"; style="color:green;">Žádost byla přijatá!</style></b>';

	}
// If there was no submit variable passed to the script (i.e. user has visited the page without clicking submit), display the form:
?>
<!--
<details>
<summary style="color:blue">Instrukcja przekierowania:</summary>
<p class="next">Przekierowanie poczty e-mail pracownika firmy może dostosować pracownik osobiście lub kierownik\zastępca kierownika jednostki. Przekazywanie wiadomości e-mail może być zainstalowany tylko na jednego pracownika.
<p class="next">Przetwarzanie wniosku zajmuje 5 minut.
<p class="next"><b><u>Uwaga! Wynik przetwarzania żądania przychodzi na adres zleceniodawcy. Inicjator wniosku wypełniane automatycznie w polu "Inicjator".</u></b>
<h3>Przekazywanie wiadomości e-mail przez pracownika</h3>
<h4>Ustawienie przekierowania e-mail pracownika</h4>
<p class="next">Do przekazywania e-mail pracownika należy:
<ul>
<li> Wybrać w polu <b>Do</b> znaczenie imienia i NAZWISKA z listy pracowników,</li>
<li> Kliknij przycisk <b>"Ustawić przekazywanie połączeń"</b>.</li>
</ul>
<i>Uwaga. Podczas instalacji przekazywania e-mail kierownika jednostki organizacyjnej dla siebie na liście "Odbiorca" wyświetlane są tylko pracownicy jednostki.</i>
<h4>Zdejmowanie przekazywania e-mail pracownika</h4>
<p class="next">Do usuwania przekierowania e-mail pracownika, należy nacisnąć przycisk <b>"Usunąć przekierowanie"</b>.
<h3>Przekazywanie e-mail kierownikiem\zastępca kierownika jednostki organizacyjnej do pracownika</h3>
<h4>Ustawienie przekierowania dla pracownika</h4>
<p class="next">Do przekazywania e-mail pracownika kierownikowi\zastępca kierownika oddziału należy:
<ul>
<li> Wybrać w polu <b>"Nadawca"</b> znaczenie imienia i NAZWISKA z listy.</li>
 <p><i>Uwaga. Dla kierownika jednostki w liście "Nadawca" wyświetlane są tylko pracownicy jednostki.</i>
<li> Wybrać w polu <b>Do</b> znaczenie imienia i NAZWISKA z listy.</li>
<p><i>Uwaga. Dla kierownika jednostki w liście "Nadawca" wyświetlane są tylko pracownicy jednostki.</i>
<li> Kliknij przycisk <b>"Ustawić przekazywanie połączeń"</b>.</li>
</ul>
<h4>Usuwanie przekierowania dla pracownika</h4>
<p class="next">Do usuwania przekierowanie poczty e-mail dla pracownika kierownikowi\zastępca kierownika należy:
<ul>
 <li> Wybrać w polu <b>"Nadawca"</b> imię i NAZWISKO pracownika, u którego należy usunąć przekierowanie.</li>
<li> Kliknij przycisk <b>"Usunąć przekierowanie"</b>.</li>
</ul>

-->


</body>
</html>