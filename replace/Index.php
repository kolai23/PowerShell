<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<link rel="stylesheet" href="css\style.css">

<title>Staff replacement</title>
</head>
<style>

	body {
	background: #dadbe0;
 	font-family: 'Roboto', sans-serif;	
	 height: 100%;
	}

	.decor {
	position: relative;
	max-width: 700px;
	margin: 20px auto 0px;
	background: white;
	border-radius: 30px;
    padding-bottom: 24px;
	}

	.form-inner {
	padding: 30px;
	
	}
	.form-inner input {
	display: block;
	width: 100%;
	padding: 0 10px;
	margin-bottom: 10px;
	background: #E9EFF6;
	line-height: 40px;
	border-width: 0;
	border-radius: 20px;
	font-family: 'Roboto', sans-serif;
	}

	.form-inner select{
	display: block;
	width: 100%;
	height: 40px;
	padding: 0 20px;
	margin-bottom: 10px;
	background: #E9EFF6;
	line-height: 40px;
	border-width: 0;
	border-radius: 20px;
	font-family: 'Roboto', sans-serif;
	
	}

	.form-inner input[type="submit"] {
	font-family: 'Roboto', sans-serif;
	margin-top: 10px;
	background: #aaadb8;
	color: white;
	font-size: 14px;
	font-weight: 500;
	
	}
	.form-inner input[type="button"] {
	font-family: 'Roboto', sans-serif;
	margin-top: 10px;
	background: #aaadb8;
	color: white;
	font-size: 14px;
	font-weight: 500;
	
	}

	.form-inner textarea {
	resize: none;
	}
	.form-inner h3 {
	margin-top: 0;
	font-family: 'Roboto', sans-serif;
	font-weight: 400;
	font-size: 24px;
	color: #707981;
	margin-left: auto;
    margin-right: auto
	}



</style>

<body>

<form name="myForm" class="decor" method="post">
	<div class="form-inner">
		<h3>Сервис замещения сотрудника на кратковременный период для электронной почты и ИС TELS</h3>

		<div align="left">Инициатор<input type="text" name="initiator" id="initiator" maxlength="60" value="<?php echo $_SERVER['AUTH_USER'] ?>" size="21">
		</div>
		<div align="left">Лицо замещаемое
			<?php
				$string=$_SERVER['AUTH_USER'];
				$string = str_replace('CAPITAL\\', '', $string);
				$string_txt= $string.".txt";
				if(file_exists("Managers/$string_txt")) {	
					$file = file("Managers/$string_txt");
					echo '<select name="sender">';
					foreach($file as $key=>$value){
					echo '<option>'.$value.'</option>';
					}
					echo '</select>';
					} else {
					echo '<input type="text" name="sender" readonly="true" id="sender" maxlength="60" value='.$string.' size="21">';
					}		
			?>
		</div>
		<div>Лицо замещающее
			<?php
				$file = file("Managers/users.txt");
				echo '<select name="recipient" id="recipient" onchange="fun1()">';
				echo "'<option value='1'>------Выберите сотрудника-----</option>'";
				foreach($file as $key=>$value)
				{
					echo '<option>'.$value.'</option>';	
				}
				echo '</select>';
			?>
		</div>
		<div align="left">Дата с
			<?php $dt_start = new DateTime(); echo '<input type="date" name="start_date" id="start_date" maxlength="60" value="' .$dt_start->format('Y-m-d'). '" size="21">' ?>
		</div>
		<div align="left">Дата по
			<?php $dt_end = new DateTime('now +14 day'); echo '<input type="date" name="end_date" id="end_date" maxlength="60" value="' .$dt_end->format('Y-m-d'). '" size="21">' ?>
		</div>

		<div>
			<input type="button" id="showDialog" value ='Установить замещающего' onclick="fun3()">
			<input type="button" name="clear" id="clear" value ='Снять замещающего' onclick="fun4()">
		</div>
		<b><p id="status" align="center"; style="color:green;"></style></b>

	</div>

	<dialog id="favDialog" aria-labelledby="dialog_title" aria-describedby="dialog_description">
		<div method="dialog" class="modal-dialog">

			<p id="demo"></p>

			<div class="flex flex-space-between">
				<button name="set" id="set" value="default">Да</button>
				<button value="cancel">Нет</button>
			</div>
		</div>
	</dialog>

	<dialog id="favDialog1" aria-labelledby="dialog_title" aria-describedby="dialog_description">
		<div method="dialog" class="modal-dialog">

			<p id="demo1"></p>

			<div class="flex flex-space-between">
				<button name="clear" id="clear" value="default">Да</button>
				<button value="cancel">Нет</button>
			</div>
		</div>
	</dialog>

</form>

<script>
	var languagesSelect = myForm.recipient;
	var selection = document.getElementById("demo");
	var sel_start_date = document.getElementById("start_date");
	var sel_end_date = document.getElementById("end_date");
	var sel_sender = document.getElementById("sender");
	var status = document.getElementById("status");

	function validate() {
		let a = document.forms["myForm"]["initiator"].value;
		if (a == "") {
			alert("Укажите ваше инициатора");
			return false;
		}
		let b = document.forms["myForm"]["sender"].value;
		if (b == "") {
			alert("Укажите лицо замещаемое");
			return false;
		}
		let с = document.forms["myForm"]["recipient"].value;
		if (с == "1") {
			alert("Укажите лицо замещающее");
			return false;
		}
		let d = document.forms["myForm"]["start_date"].value;
		var d1 = new Date ();
		var d2= new Date (d);

		if (d == "") {
			alert("Выберите дату начала замещени");
			return false;
		}
		if (d2.getDate() < d1.getDate() || d2.getMonth() < d1.getMonth() || d2.getYear() < d1.getYear()) {
			alert("Выберите коректною дату начала замещени, не меньше текущей");
			return false;
		}

		let e = document.forms["myForm"]["end_date"].value;
		if (e == "") {
			alert("Выберите дату завершения замещения");
			return false;
		}

		if (d2.getDate() < d1.getDate() || d2.getMonth() < d1.getMonth() || d2.getYear() < d1.getYear()) {
			alert("Выберите коректною дату завершения замещения, не меньше текущей");
			return false;
		}

		return  true;
    }

	function fun1() { 
		var selectedOption = languagesSelect.options[languagesSelect.selectedIndex];
		selection.textContent = "Установить замещение сотрудника " + sel_sender.value + " сотрудником " + selectedOption.text + " на период с " + sel_start_date.value + " по "+ sel_end_date.value + "?";
		document.getElementById("demo").innerHTML = selection.textContent;
	}

	function fun2() { 
		var selection = document.getElementById("demo1");
		var status_erroe = "Снять замещение сотрудника " + sel_sender.value + "c <?php echo $dt_start->format('d.m.Y') ?>";
		document.getElementById("demo1").innerHTML = status_erroe;
	}

	function fun3() { 
		const showButton = document.getElementById('showDialog');
		const clearButton = document.getElementById('clear');
		const favDialog = document.getElementById('favDialog');

		var myFalse = new Boolean(false);

		myFalse = validate();

		if(myFalse){
			showButton.addEventListener('click', () => {
			favDialog.showModal();
			fun1();
			});
		}
		
		favDialog.addEventListener('close', () => {
		outputBox.value = `ReturnValue: ${favDialog.returnValue}.`;
		});
	}

	function fun4() { 

		const showButton1 = document.getElementById('clear');
		const clearButton = document.getElementById('clean');
		const favDialog1 = document.getElementById('favDialog1');

		showButton1.addEventListener('click', () => {
			favDialog1.showModal();
			fun2();
		});


		favDialog1.addEventListener('close', () => {
		outputBox.value = `ReturnValue: ${favDialog1.returnValue}.`;
		});
		
	}

</script>

	<?php
		if(isset($_POST["set"]) and (!(empty($_POST["sender"]))))
		{	
			//создаем объект DateTime с текущей датой
			$date = date_create();
			$timeStart = strtotime($_POST['start_date']);
			$timeEnd = strtotime($_POST['end_date']);
			//определяем имя файла
			$file_name =$string. "_" .date_format($date, 'sidmY') . ".txt";
			// Открыть текстовый файл
			$f = fopen("C:\\Inetpub\\Replace\\Requests\\".$file_name, "w+");
			fwrite($f,$string."\r\n".$_POST['sender']."\r\n".$_POST["recipient"]."\r\n"."set"."\r\n".date('Ymd',$timeStart)."\r\n".date('Ymd',$timeEnd)."\r\n"); 
			fclose($f);
			echo '<b><p align="center"; style="color:green;">Заявка принята!</style></b>';
			}  else if(isset($_POST["clear"]))
		{	
			//создаем объект DateTime с текущей датой
			$date = date_create();
			//определяем имя файла
			$file_name =$string. "_" .date_format($date, 'sidmY') . ".txt";
			// Открыть текстовый файл
			$f = fopen("C:\\Inetpub\\Replace\\Requests\\".$file_name, "w+");
			fwrite($f,$string."\r\n".$_POST['sender']."\r\n".$_POST["recipient"]."\r\n"."clear"."\r\n"); 
			fclose($f);
			echo '<b><p align="center"; style="color:red;">Заявка на снятие принята!</style></b>';
		}
	?>

</body>
</html>