package com.ditcalendar.bot.data

import kotlinx.serialization.Serializable

typealias TelegramLinks = List<TelegramLink>

@Serializable
data class TelegramLink(val chatId: Long,
                        val userId: Int,
                        val userName: String? = null,
                        val firstName: String?)