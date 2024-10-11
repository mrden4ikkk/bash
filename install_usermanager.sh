#!/bin/bash

# Функція для додавання нового користувача
add_user() {
    read -p "Введіть ім'я користувача: " username
    sudo adduser "$username"
    echo "Користувача $username додано."
}

# Функція для видалення користувача
delete_user() {
    read -p "Введіть ім'я користувача для видалення: " username
    sudo deluser "$username"
    echo "Користувача $username видалено."
}

# Функція для зміни пароля користувача
change_password() {
    read -p "Введіть ім'я користувача для зміни пароля: " username
    sudo passwd "$username"
}

# Функція для відображення списку користувачів
list_users() {
    echo "Список користувачів:"
    cut -d: -f1 /etc/passwd
}

# Основне меню
while true; do
    echo "------ УПРАВЛІННЯ КОРИСТУВАЧАМИ ------"
    echo "1. Додати користувача"
    echo "2. Видалити користувача"
    echo "3. Змінити пароль користувача"
    echo "4. Показати всіх користувачів"
    echo "5. Вийти"

    read -p "Виберіть опцію [1-5]: " option

    case $option in
        1)
            add_user
            ;;
        2)
            delete_user
            ;;
        3)
            change_password
            ;;
        4)
            list_users
            ;;
        5)
            echo "Вихід..."
            exit 0
            ;;
        *)
            echo "Некоректний вибір, спробуйте ще раз."
            ;;
    esac

    echo ""
done

