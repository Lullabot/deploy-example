<?php

namespace Drush\Commands;

use Symfony\Component\Process\Process;
use Symfony\Component\Process\Exception\ProcessFailedException;

/**
 * A Drush commandfile.
 */
class DrushBuildCommands extends DrushCommands {

  /**
   * Drush build command.
   *
   * @command build
   */
  public function build() {

    $this->logger()->notice(dt('This command will rebuild your artifacts.'));

    if ($this->io()->confirm(dt('Are you sure you want to continue?'), TRUE)) {

      // Create artifacts.
      $this->runShellCommand("composer install --optimize-autoloader");
      $this->runShellCommand("mkdir -p web/themes/custom/deploy_example_theme/js");
      $this->runShellCommand("mkdir -p web/themes/custom/deploy_example_theme/css");
      $this->runShellCommand("mkdir -p web/themes/custom/deploy_example_theme/node_modules");
      $this->runShellCommand("(cd web/themes/custom/deploy_example_theme && npm install)");
      $this->runShellCommand("(cd web/themes/custom/deploy_example_theme && npm run build)");
      $this->runShellCommand("drush cache:rebuild");

      $this->logger()->success(dt('Site build successful.'));
    }
  }

  /**
   * A helper function to run commands like shell commands.
   *
   * @param string $command
   *   The shell command to run.
   * @param int|float|null $timeout
   *   The timeout in seconds.
   */

  public function runShellCommand($command, $timeout = NULL) {
    $process = new Process($command, NULL, NULL, NULL, $timeout);
    $process->run();
    if (!$process->isSuccessful()) {
      throw new ProcessFailedException($process);
    }
    echo $process->getOutput();
  }
}
