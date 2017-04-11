<?php


// GESTION BDD #############

// connexion à la bdd

function connBdd() {
	$create = !file_exists("journal.db");
  try { $db = new PDO("sqlite:journal.db"); }
  catch(PDOException $e) {
    echo $e->getMessage();
    return;
  }
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
  try {
    $db->beginTransaction();
    $stmt = $db->prepare("INSERT INTO journal VALUES(CURRENT_TIMESTAMP,:idx,:type,:detail);");
    $stmt->bindParam(":idx",$_GET["arg"]);
    $stmt->bindParam(":type",$mod);
    $stmt->bindParam(":detail",$_POST["detail"]);
    $stmt->execute();
    $db->commit();
    echo "ok";
  }
  catch(PDOException $e) {
    echo $e->getMessage();
  }
}

// récupération des données de synchro

function getSynchro() {
	if (!isset($_GET["arg"]) || !isset($_POST["detail"])) { echo "I need to sleep..."; return; }
	$db = connBdd();
  $arg = $_GET["arg"] . '%';
	$db->beginTransaction();
  $stmt = $db->prepare("SELECT * FROM journal WHERE idx NOT LIKE :idx AND date > :detail ORDER BY date;");
  $stmt->bindParam(":idx",$arg);
  $stmt->bindParam(":detail",$_POST["detail"]);
  $stmt->execute();
  $json = array('list' => array(),'last' => '0');
  while ($row = $stmt->fetch(PDO::FETCH_ASSOC, PDO::FETCH_ORI_NEXT)) {
    $json['list'][] = $row['date'];
    $json['last'] = $row['date'];
    $json[$row['idx']] = array('idx'=>$row['idx'], 'action'=>$row['action'], 'detail'=>$row['detail']);
  }
	$db->commit();
  echo json_encode($json);
}

// bad request

function badrequest() {
	echo "there is an error somewhere... over the rainbow maybe?";
}

// ROUTER ##################

if (isset($_GET["cmd"])) {
	switch ($_GET["cmd"]) {
		case "synchro": getSynchro(); break;
		case "add": bddRequest("add","the debate turned mad."); break;
		case "remove": bddRequest("rem","What's wrong with you?"); break;
		case "mod": bddRequest("mod","I did it!"); break;
		case "404":
		default: badrequest(); break;
	}
}
else echo "oh no !";

?>
