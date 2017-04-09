<?php


// GESTION BDD #############

// connexion à la bdd

function connBdd() {
	$create = !file_exists("journal.db");
	$db = new PDO("sqlite:journal.db");
	if ($create) {
		$db->beginTransaction();
		$db->exec("CREATE TABLE journal (date TIMESTAMP,idx TEXT,action TEXT,detail TEXT);");
		$db->commit();
	}
	return $db;
}

// insert bdd request

function bddRequest($mod,$msg) {
	if (!isset($_GET["arg"]) || !isset($_POST["detail"])) { echo $msg; return; }
	$db = connBdd();
	$db->beginTransaction();
	$stmt = $db->prepare("INSERT INTO journal VALUES(CURRENT_TIMESTAMP,:idx,:type,:detail);");
	$stmt->bindParam(":idx",$_GET["arg"]);
	$stmt->bindParam(":type",$mod);
	$stmt->bindParam(":detail",$_POST["detail"]);
	$stmt->execute();
	$db->commit();
}

// récupération des données de synchro

function setSynchro() {
	if (!isset($_GET["arg"])) { echo "I need to sleep..."; return; }
	$db = connBdd();
	$bd->beginTransaction();
	//
	//
	$db->commit();
}

// bad request

function badrequest() {
	echo "there is an error somewhere... over the rainbow maybe?";
}

// ROUTER ##################

if (isset($_GET["cmd"])) {
	switch ($_GET["cmd"]) {
		case "synchro": setSynchro(); break;
		case "add": bddRequest("add","the debate turned mad."); break;
		case "remove": bddRequest("rem","What's wrong with you?"); break;
		case "mod": bddRequest("mod","I did it!"); break;
		case "404":
		default: badrequest(); break;
	}
}
else echo "oh no !";

?>