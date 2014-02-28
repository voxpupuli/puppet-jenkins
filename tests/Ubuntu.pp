node default {
    include stdlib
    include jenkins

    jenkins::plugin {
        'ansicolor' :
            version => '0.3.1';
    }
}
