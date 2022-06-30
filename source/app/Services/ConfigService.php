<?php

declare(strict_types=1);

namespace App\Services;

use App\Http\Requests\ConfigCreateRequest;

class ConfigService extends ServiceBase
{
    /**
     * Create service
     *
     * @param array<string> $data
     *
     * @return ConfigService
     */
    public function create(array $data): ConfigService
    {
        $validated = $this->validate($data, ConfigCreateRequest::class);

        return $this;
    }
}
