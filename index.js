const { Client, GatewayIntentBits, PermissionsBitField, ActionRowBuilder, ButtonBuilder, ButtonStyle, EmbedBuilder } = require('discord.js');
const client = new Client({ intents: [GatewayIntentBits.Guilds, GatewayIntentBits.GuildMessages, GatewayIntentBits.MessageContent] });

// ===================== CONFIGURAÇÃO =====================
const donoID = ''; // coloque seu ID do Discord
const canalScriptsNome = '📜-scripts'; // nome do canal onde os scripts serão enviados

// Armazena os canais travados
const canaisTravados = new Set();

// ===================== COMANDOS DE LOCK / UNLOCK =====================
client.on('messageCreate', async message => {
    if (message.author.bot) return;

    const command = message.content.toLowerCase();

    // ------------------ TRAVAR CANAL ------------------
    if (command === '!nexolock') {
        if (message.author.id !== donoID) return;

        const canal = message.channel;
        if (canaisTravados.has(canal.id)) {
            return message.channel.send(`${canal} já está travado!`);
        }

        await canal.permissionOverwrites.edit(message.guild.roles.everyone, {
            SendMessages: false
        });

        canaisTravados.add(canal.id);
        canal.send(`${canal} travado com sucesso! 🔒`);
    }

    // ------------------ DESBLOQUEAR CANAL ------------------
    if (command === '!nexounlock') {
        if (message.author.id !== donoID) return;

        const canal = message.channel;
        if (!canaisTravados.has(canal.id)) {
            return message.channel.send(`${canal} já está destravado!`);
        }

        await canal.permissionOverwrites.edit(message.guild.roles.everyone, {
            SendMessages: true
        });

        canaisTravados.delete(canal.id);
        canal.send(`${canal} destravado com sucesso! 🔓`);
    }

    // ------------------ BLOQUEIO DE MENSAGENS ------------------
    if (canaisTravados.has(message.channel.id) && message.author.id !== donoID) {
        message.delete().catch(() => {});

        message.channel.send(`${message.author}, Você é meu dono por acaso? 😎`).then(msg => {
            setTimeout(() => msg.delete().catch(() => {}), 5000);
        });
    }
});

// ===================== ENVIO AUTOMÁTICO DE SCRIPTS =====================
client.once('ready', async () => {
    console.log(`Bot online como ${client.user.tag}`);

    const guild = client.guilds.cache.first();
    const canal = guild.channels.cache.find(c => c.name === canalScriptsNome);

    if (!canal) return console.log(`Canal #${canalScriptsNome} não encontrado`);

    const enviarScripts = async () => {
        const embed = new EmbedBuilder()
            .setTitle('📜 Scripts Nexo')
            .setColor('#00A2FF')
            .setDescription(
                '**🔥 Nexo v1**\n' +
                '```lua\nloadstring(game:HttpGet("https://amaliacriptbeta.vercel.app/script.lua"))()\n```\n\n' +
                '**⚡ Nexo v2**\n' +
                '```lua\nloadstring(game:HttpGet("https://raw.githubusercontent.com/Jayb113/Amaliacriptbeta/refs/heads/main/NexoV2.lua"))()\n```'
            )
            .setFooter({ text: 'Escolhe qual queres copiar 👇' });

        const botoes = new ActionRowBuilder().addComponents(
            new ButtonBuilder()
                .setLabel('Copiar Nexo v1')
                .setCustomId('copiar_v1')
                .setStyle(ButtonStyle.Primary),

            new ButtonBuilder()
                .setLabel('Copiar Nexo v2')
                .setCustomId('copiar_v2')
                .setStyle(ButtonStyle.Success)
        );

        await canal.send({ embeds: [embed], components: [botoes] });
    };

    // Envia imediatamente e depois a cada 1 hora
    enviarScripts();
    setInterval(enviarScripts, 3600000); // 3.600.000 ms = 1 hora
});

// ===================== EVENTO DOS BOTÕES =====================
client.on('interactionCreate', async interaction => {
    if (!interaction.isButton()) return;

    if (interaction.customId === 'copiar_v1') {
        await interaction.reply({
            content: '```lua\nloadstring(game:HttpGet("https://amaliacriptbeta.vercel.app/script.lua"))()\n```',
            ephemeral: true
        });
    }

    if (interaction.customId === 'copiar_v2') {
        await interaction.reply({
            content: '```lua\nloadstring(game:HttpGet("https://raw.githubusercontent.com/Jayb113/Amaliacriptbeta/refs/heads/main/NexoV2.lua"))()\n```',
            ephemeral: true
        });
    }
});

// ===================== LOGIN =====================
client.login(''); // coloque o token do seu bot aqui
