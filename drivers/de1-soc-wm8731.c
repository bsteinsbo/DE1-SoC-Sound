/*
 * de1-soc-wm8731 -- SoC audio for Terasic DE1-SoC board
 * Author: B. Steinsbo <bsteinsbo@gmail.com>
 *
 * Based on sam9g20_wm8731 by
 * Sedji Gaouaou <sedji.gaouaou@atmel.com>
 *
 * Licensed under the GPL-2.
 */

#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/clk.h>
#include <linux/platform_device.h>
#include <linux/of.h>
#include <linux/gpio.h>
#include <linux/of_gpio.h>

#include <sound/core.h>
#include <sound/pcm.h>
#include <sound/pcm_params.h>
#include <sound/soc.h>

#define WM8731_SYSCLK_XTAL 1
#define WM8731_SYSCLK_MCLK 2
#define MCLK_RATE_48K 12288000 /* fs*256 */
#define MCLK_RATE_44K 16934400 /* fs*384 */

static unsigned int i2c_mux_gpio;

static int de1soc_hw_params(struct snd_pcm_substream *substream,
	struct snd_pcm_hw_params *params)
{
	struct snd_soc_pcm_runtime *rtd = substream->private_data;
	struct snd_soc_dai *codec_dai = rtd->codec_dai;
	struct device *dev = rtd->card->dev;
	unsigned int mclk_freq;
	int ret;

	if ((params_rate(params) % 44100) == 0) {
		mclk_freq = MCLK_RATE_44K;
	} else if ((params_rate(params) % 48000) == 0) {
		mclk_freq = MCLK_RATE_48K;
	} else
		return -EINVAL;

	/* set codec mclk configuration */
	ret = snd_soc_dai_set_sysclk(codec_dai, WM8731_SYSCLK_MCLK,
		mclk_freq, SND_SOC_CLOCK_OUT);
	if (ret < 0)
		return ret;

	dev_dbg(dev, "hw_params: mclk_freq=%d\n", mclk_freq);
	return 0;
}

static void de1soc_shutdown(struct snd_pcm_substream *substream)
{
	struct snd_soc_pcm_runtime *rtd = substream->private_data;
	struct snd_soc_dai *codec_dai = rtd->codec_dai;
	struct device *dev = rtd->card->dev;
	int ret;

	dev_dbg(dev, "shutdown\n");
	ret = snd_soc_dai_set_sysclk(codec_dai, WM8731_SYSCLK_MCLK,
		0, SND_SOC_CLOCK_OUT);
	if (ret < 0) {
		dev_err(dev, "Failed to reset WM8731 SYSCLK: %d\n", ret);
	}
}

static struct snd_soc_ops de1soc_ops = {
	// .startup
	.shutdown = de1soc_shutdown,
	.hw_params = de1soc_hw_params,
	// .hw_free
	// .prepare
	// .trigger
};

static const struct snd_soc_dapm_widget de1soc_dapm_widgets[] = {
	SND_SOC_DAPM_HP("Headphone Jack", NULL),
	SND_SOC_DAPM_MIC("Microphone Jack", NULL),
	SND_SOC_DAPM_LINE("Line In Jack", NULL),
	SND_SOC_DAPM_LINE("Line Out Jack", NULL),
};

static const struct snd_soc_dapm_route intercon[] = {
	{"MICIN", NULL, "Mic Bias"},
	{"Mic Bias", NULL, "Microphone Jack"},
	{"LLINEIN", NULL, "Line In Jack"},
	{"RLINEIN", NULL, "Line In Jack"},
	{"Line Out Jack", NULL, "LOUT"},
	{"Line Out Jack", NULL, "ROUT"},
	{"Headphone Jack", NULL, "LHPOUT"},
	{"Headphone Jack", NULL, "RHPOUT"},
};

static int de1soc_wm8731_init(struct snd_soc_pcm_runtime *rtd)
{
	struct snd_soc_dai *codec_dai = rtd->codec_dai;
	struct snd_soc_dai *cpu_dai = rtd->cpu_dai;
	struct device *dev = rtd->card->dev;
	unsigned int fmt;
	int ret;

	dev_dbg(dev, "init\n");

	fmt = SND_SOC_DAIFMT_I2S | SND_SOC_DAIFMT_NB_NF |
	      SND_SOC_DAIFMT_CBS_CFS;

	/* set cpu DAI configuration */
	ret = snd_soc_dai_set_fmt(cpu_dai, fmt);
	if (ret < 0)
		return ret;

	/* set codec DAI configuration */
	ret = snd_soc_dai_set_fmt(codec_dai, fmt);
	if (ret < 0)
		return ret;

	/* Don't let codec constraints interfere */
	ret = snd_soc_dai_set_sysclk(codec_dai, WM8731_SYSCLK_MCLK,
		0, SND_SOC_CLOCK_OUT);
	if (ret < 0) {
		dev_err(dev, "Failed to set WM8731 SYSCLK: %d\n", ret);
		return ret;
	}

	return 0;
}

static struct snd_soc_dai_link de1soc_dai = {
	.name = "WM8731",
	.stream_name = "WM8731 PCM",
	.cpu_dai_name = "ff200000.i2s",
	.codec_dai_name = "wm8731-hifi",
	.init = de1soc_wm8731_init,
	.platform_name = "de1soc",
	.codec_name = "wm8731.0-001a",
	.ops = &de1soc_ops,
};

static struct snd_soc_card snd_soc_de1soc = {
	.name = "DE1SOC-WM8731",
	.owner = THIS_MODULE,
	.dai_link = &de1soc_dai,
	.num_links = 1,

	.dapm_widgets = de1soc_dapm_widgets,
	.num_dapm_widgets = ARRAY_SIZE(de1soc_dapm_widgets),
	.dapm_routes = intercon,
	.num_dapm_routes = ARRAY_SIZE(intercon),
};

static int de1soc_audio_probe(struct platform_device *pdev)
{
	struct device_node *np = pdev->dev.of_node;
	struct device_node *codec_np, *cpu_np;
	struct snd_soc_card *card = &snd_soc_de1soc;
	int ret;

	if (!np) {
		return -ENODEV;
	}

	card->dev = &pdev->dev;

	/* I2C bus is muxed between HPS and FPGA. Set mux to HPS */
	i2c_mux_gpio = of_get_named_gpio(np, "i2c-mux-gpio", 0);
	if (gpio_is_valid(i2c_mux_gpio)) {
		ret = devm_gpio_request_one(&pdev->dev,
			i2c_mux_gpio, GPIOF_OUT_INIT_LOW, "I2C_MUX");
		if (ret) {
			dev_err(&pdev->dev,
				"Failed to request GPIO_%d for i2c_mux: %d\n",
				i2c_mux_gpio, ret);
			return ret;
		}
		gpio_set_value(i2c_mux_gpio, 1);
	}

	/* Parse codec info */
	de1soc_dai.codec_name = NULL;
	codec_np = of_parse_phandle(np, "audio-codec", 0);
	if (!codec_np) {
		dev_err(&pdev->dev, "codec info missing\n");
		return -EINVAL;
	}
	de1soc_dai.codec_of_node = codec_np;

	/* Parse dai and platform info */
	de1soc_dai.cpu_dai_name = NULL;
	de1soc_dai.platform_name = NULL;
	cpu_np = of_parse_phandle(np, "i2s-controller", 0);
	if (!cpu_np) {
		dev_err(&pdev->dev, "dai and pcm info missing\n");
		return -EINVAL;
	}
	de1soc_dai.cpu_of_node = cpu_np;
	de1soc_dai.platform_of_node = cpu_np;

	of_node_put(codec_np);
	of_node_put(cpu_np);

	ret = snd_soc_register_card(card);
	if (ret) {
		dev_err(&pdev->dev, "snd_soc_register_card() failed\n");
	}

	return ret;
}

static int de1soc_audio_remove(struct platform_device *pdev)
{
	struct snd_soc_card *card = platform_get_drvdata(pdev);

	if (gpio_is_valid(i2c_mux_gpio))
		devm_gpio_free(&pdev->dev, i2c_mux_gpio);

	snd_soc_unregister_card(card);

	return 0;
}

static const struct of_device_id de1soc_wm8731_dt_ids[] = {
	{ .compatible = "opencores,de1soc-wm8731-audio", },
	{ }
};
MODULE_DEVICE_TABLE(of, de1soc_wm8731_dt_ids);

static struct platform_driver de1soc_audio_driver = {
	.driver = {
		.name	= "de1soc-audio",
		.owner	= THIS_MODULE,
		.of_match_table = of_match_ptr(de1soc_wm8731_dt_ids),
	},
	.probe	= de1soc_audio_probe,
	.remove	= de1soc_audio_remove,
};

module_platform_driver(de1soc_audio_driver);

/* Module information */
MODULE_AUTHOR("Bjarne Steinsbo <bsteinsbo@gmail.com>");
MODULE_DESCRIPTION("ALSA SoC DE1-SoC_WM8731");
MODULE_LICENSE("GPL");
