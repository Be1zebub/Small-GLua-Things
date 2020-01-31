<?php 
    /*—————————————————————————————————————————
             Developer: [INC]Be1zebub

         Website: incredible-gmod.ru/owner
        EMail: beelzebub@incredible-gmod.ru
        Discord: discord.incredible-gmod.ru
    —————————————————————————————————————————*/
    
    $avatar_url = $_POST["avatar_url"];
    $username = $_POST["username"];
    $content = $_POST["content"];
    $message = " " . $content;
    $url = $_POST["url"];
    $data = array("content" =>$message , "username" =>$username, "avatar_url" =>$avatar_url);
    $options = array( 'http' => array( 'header' => "Content-type: application/x-www-form-urlencoded\r\n", 'method' => 'POST', 'content' => http_build_query($data) ) ); 
    $context = stream_context_create($options); $result = file_get_contents($url, false, $context); if ($result === FALSE) { /* Handle error */ } 
?>
